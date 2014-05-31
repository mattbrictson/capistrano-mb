fiftyfive_recipe :aptitude do
  during :provision, %w(upgrade install)
end

namespace :fiftyfive do
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

    def _already_installed?(pkg)
      test(:dpkg, "-s", pkg, "2>/dev/null", "|", :grep, "-q 'ok installed'")
    end

    def _add_repository(repo)
      unless _already_installed?("python-software-properties")
        _install("python-software-properties")
      end
      execute :"apt-add-repository", "-y", repo
    end

    def _install(pkg)
      with :debian_frontend => "noninteractive" do
        execute :aptitude, "-y -q install", pkg
      end
    end

    def _update
      with :debian_frontend => "noninteractive" do
        execute :aptitude, "-q -q -y update"
      end
    end

    def _safe_upgrade
      with :debian_frontend => "noninteractive" do
        execute :aptitude, "-q -q -y safe-upgrade"
      end
    end

    def _each_package(host)
      return to_enum(:_each_package, host) unless block_given?

      fetch(:fiftyfive_aptitude_packages).each do |package_spec, *role_list|
        next unless roles(*role_list.flatten).include?(host)

        pkg, repo = package_spec.split("@")
        yield(pkg, repo)
      end
    end
  end
end
