mb_recipe :seed do
  prior_to "deploy:publishing", "mb:seed"
end

namespace :mb do
  desc "Run rake db:seed"
  task :seed do
    on primary(:app) do
      within release_path do
        with :rails_env => fetch(:rails_env) do
          execute :rake, "db:seed"
        end
      end
    end
  end
end
