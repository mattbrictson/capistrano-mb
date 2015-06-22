mb_recipe :version do
  during "deploy:updating", "write_initializer"
end

namespace :mb do
  namespace :version do
    desc "Write initializers/version.rb with git version and date information"
    task :write_initializer do
      git_version = {}
      branch = fetch(:branch)

      on release_roles(:all).first do
        with fetch(:git_environmental_variables) do
          within repo_path do
            git_version[:tag] = \
              capture(:git, "describe", branch, "--always --tag").chomp
            git_version[:date] = \
              capture(:git, "log", branch, '-1 --format="%ad" --date=short')\
              .chomp
            git_version[:time] = \
              capture(:git, "log", branch, '-1 --format="%ad" --date=iso')\
              .chomp
          end
        end
      end

      on release_roles(:all) do
        template "version.rb.erb",
                 "#{release_path}/config/initializers/version.rb",
                 :binding => binding
      end
    end
  end
end
