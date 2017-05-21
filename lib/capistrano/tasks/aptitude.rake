mb_recipe :aptitude do
  during :provision, %w(upgrade install)
  before "provision:14_04", "mb:aptitude:install_software_properties"
  before "provision:14_04", "mb:aptitude:install_postgres_repo"
  before "provision:14_04", "mb:aptitude:change_postgres_packages"
end

namespace :mb do
  namespace :aptitude do

    desc "Run `aptitude update` and then run `aptitude safe-upgrade`"
    task :upgrade do
      privileged_on roles(:all) do |host|
        _update
        _safe_upgrade
      end
    end


    desc "Run `aptitude install` for packages required by the roles of "\
         "each server."
    task :install do
      privileged_on roles(:all) do |host|
        packages_to_install = []
        repos_to_add = []

        _each_package(host) do |pkg, repo|
          unless _already_installed?(pkg)
            repos_to_add << repo unless repo.nil?
            packages_to_install << pkg
          end
        end

        repos_to_add.uniq.each { |repo| _add_repository(repo) }
        _update
        packages_to_install.uniq.each { |pkg| _install(pkg) }
      end
    end

    desc "Add the official apt repository for PostgreSQL"
    task :install_postgres_repo do
      privileged_on roles(:all) do |host|
        _add_repository(
          "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main",
          :key => "https://www.postgresql.org/media/keys/ACCC4CF8.asc")
      end
    end

    desc "Change 12.04 PostgreSQL package requirements to 14.04 versions"
    task :change_postgres_packages do
      packages = fetch(:mb_aptitude_packages, {})
      packages = Hash[packages.map do |key, value|
        [key.sub(/@ppa:pitti\/postgresql$/, ""), value]
      end]
      set(:mb_aptitude_packages, packages)
    end

    desc "Install package needed for apt-add-repository on 14.04"
    task :install_software_properties do
      privileged_on roles(:all) do |host|
        unless _already_installed?("software-properties-common")
          _install("software-properties-common")
        end
      end
    end

    def _already_installed?(pkg)
      test(:sudo, "dpkg", "-s", pkg, "2>/dev/null", "|", :grep, "-q 'ok installed'")
    end

    def _add_repository(repo, options={})
      unless _already_installed?("python-software-properties")
        _install("python-software-properties")
      end
      execute :sudo, "apt-add-repository", "-y '#{repo}'"

      if (key = options.fetch(:key, nil))
        execute "wget --prefer-family=IPv4 --quiet -O - #{key} | sudo apt-key add -"
      end
    end

    def _install(pkg)
      with :debian_frontend => "noninteractive" do
        execute :sudo, "aptitude", "-y -q install", pkg
      end
    end

    def _update
      with :debian_frontend => "noninteractive" do
        execute :sudo, "aptitude", "-q -q -y update"
      end
    end

    def _safe_upgrade
      with :debian_frontend => "noninteractive" do
        execute :sudo, "aptitude", "-q -q -y safe-upgrade"
      end
    end

    def _each_package(host)
      return to_enum(:_each_package, host) unless block_given?
      hostname = host.hostname
      fetch(:mb_aptitude_packages).each do |package_spec, *role_list|
        next unless roles(*role_list.flatten).map(&:hostname).include?(hostname)

        pkg, repo = package_spec.split("@")
        yield(pkg, repo)
      end
    end
  end
end
