fiftyfive_recipe :migrate do
  during   "deploy:migrate_and_restart", "deploy"
  prior_to "deploy:migrate",             "enable_maintenance_before"
  during   "deploy:published",           "disable_maintenance_after"
end

namespace :fiftyfive do
  namespace :migrate do
    task :deploy do
      set(:fiftyfive_restart_during_migrate, true)
      invoke :deploy
    end

    task :enable_maintenance_before do
      if fetch(:fiftyfive_restart_during_migrate)
        invoke_if_defined "fiftyfive:maintenance:enable"
        invoke_if_defined "deploy:stop"
      end
    end

    task :disable_maintenance_after do
      if fetch(:fiftyfive_restart_during_migrate)
        invoke_if_defined "fiftyfive:maintenance:disable"
      end
    end
  end
end
