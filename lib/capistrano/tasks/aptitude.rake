mb_recipe :aptitude do
  during :provision, %w[check upgrade install]
end

namespace :mb do
  namespace :aptitude do
    desc "Verify server is Ubuntu 16.04"
    task :check do
      privileged_on roles(:all) do
        version = capture(:sudo, "lsb_release -a")[/^Release:\s+(\S+)$/, 1]
        next if version == "16.04"

        raise "Ubuntu version #{version || "unknown"} is not supported by "\
              "capistrano-mb. Only Ubuntu 16.04 is supported. Downgrade "\
              "capistrano-mb if you need to use an older version of Ubuntu."
      end
    end

    desc "Run `apt update` and then run `apt upgrade`"
    task :upgrade do
      privileged_on roles(:all) do
        _update
        _upgrade
      end
    end

    desc "Run `apt install` for packages required by the roles of "\
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
      test(:sudo,
           "dpkg", "-s", pkg,
           "2>/dev/null", "|", :grep, "-q 'ok installed'")
    end

    def _add_repository(repo)
      unless _already_installed?("software-properties-common")
        _install("software-properties-common")
      end
      execute :sudo, "apt-add-repository", "-y '#{repo}'"
    end

    def _install(pkg)
      execute :sudo, "DEBIAN_FRONTEND=noninteractive apt-get -y install", pkg
    end

    def _update
      execute :sudo, "DEBIAN_FRONTEND=noninteractive apt-get -y update"
    end

    def _upgrade
      execute :sudo,
              "DEBIAN_FRONTEND=noninteractive apt-get -y "\
              '-o DPkg::options::="--force-confdef" '\
              '-o DPkg::options::="--force-confold" '\
              "upgrade"
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
