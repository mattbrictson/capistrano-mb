fiftyfive_recipe :aptitude do
  during :provision, %w(install upgrade)
end

namespace :fiftyfive do
  namespace :aptitude do

    desc "Run `aptitude update` and then run `aptitude safe-upgrade` for "\
         "the packages required by the roles of each server."
    task :upgrade do
      privileged_on roles(:all) do |host|
        packages = _each_package(host).map { |pkg, _| pkg }

        if packages.any?
          execute :aptitude, "-q -q -y update"
          execute :aptitude, "-q -q -y safe-upgrade", *packages
        end
      end
    end


    desc "Run `aptitude install` for packages required by the roles of "\
         "each server."
    task :install do
      privileged_on roles(:all) do |host|
        _each_package(host) do |pkg, repo|
          unless _already_installed?(pkg)
            _add_repository(repo) unless repo.nil?
            _install(pkg)
          end
        end
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
      execute :aptitude, "-y -q install", pkg
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
