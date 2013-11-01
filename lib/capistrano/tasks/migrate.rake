fiftyfive_recipe :migrate do
  during "deploy:migrate", "fiftyfive:migrate"
  prior_to "deploy:publishing", "fiftyfive:migrate:when_flag_set"
  during "deploy:migrate_and_restart", "fiftyfive:migrate:deploy"
end

namespace :fiftyfive do
  task :migrate do
    on primary(:db) do
      within release_path do
        with :rails_env => fetch(:rails_env) do
          execute :rake, "db:migrate"
        end
      end
    end
  end

  namespace :migrate do
    task :deploy do
      set(:deploying, true)
      set(:fiftyfive_migrate_during_deploy, true)

      %w(starting started updating updated).each { |t| invoke "deploy:#{t}" }

      begin
        invoke_if_defined "fiftyfive:maintenance:enable"
        invoke_if_defined "deploy:stop"
        invoke "deploy:publishing"
      ensure
        invoke_if_defined "deploy:start"
        invoke_if_defined "fiftyfive:maintenance:disable"
      end

      %w(published finishing finished).each { |t| invoke "deploy:#{t}" }
    end

    task :when_flag_set do
      if fetch(:fiftyfive_migrate_during_deploy)
        invoke "fiftyfive:migrate"
      end
    end
  end
end
