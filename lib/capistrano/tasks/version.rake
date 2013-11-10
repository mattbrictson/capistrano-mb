fiftyfive_recipe :version do
  during "deploy:updating", "write_initializer"
end

namespace :fiftyfive do
  namespace :version do
    task :write_initializer do
      git_version = {}
      branch = fetch(:branch)

      on roles(:all).first do
        with fetch(:git_environmental_variables) do
          within repo_path do
            git_version[:tag] = \
              capture(:git, "describe", branch, "--always --tag").chomp
            git_version[:date] = \
              capture(:git, "log", branch, '-1 --format="%ad" --date=short')\
              .chomp
          end
        end
      end

      on roles(:all) do
        template "version.rb.erb",
                 "#{release_path}/config/initializers/version.rb",
                 :binding => binding
      end
    end
  end
end
