mb_recipe :migrate do
  during   "deploy:migrate_and_restart", "deploy"
  prior_to "deploy:migrate",             "enable_maintenance_before"
  during   "deploy:published",           "disable_maintenance_after"
end

namespace :mb do
  namespace :migrate do
    desc "Deploy the app, stopping it and showing a 503 maintenance page "\
         "while database migrations are being performed; then start the app"
    task :deploy do
      set(:mb_restart_during_migrate, true)
      invoke :deploy
    end

    task :enable_maintenance_before do
      if fetch(:mb_restart_during_migrate)
        invoke_if_defined "mb:maintenance:enable"
        invoke_if_defined "deploy:stop"
      end
    end

    task :disable_maintenance_after do
      if fetch(:mb_restart_during_migrate)
        invoke_if_defined "mb:maintenance:disable"
      end
    end
  end
end
