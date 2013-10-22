require "capistrano/fiftyfive"

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do
    namespace :deploy do
      desc "Deploy code, put app into maintenance mode, migrate, and restart"
      task :migrate_and_restart do
        migrate_steps = %w(deploy:web:disable deploy:stop deploy:migrate)
        startup_steps = %w(deploy:start deploy:web:enable)

        # Check out and symlink the latest code, but don't restart yet.
        execute_task("deploy:update")

        # Disable and stop the app, migrate the database, and restart the app.
        # If something goes wrong, roll back to the previous version of the
        # code and restart.
        begin
          execute_tasks(*migrate_steps)
        rescue
          execute_task("deploy:rollback:code")
          logger.log Capistrano::Logger::IMPORTANT,
                     "ERROR: Migration failed. "\
                     "Code has been rolled back to previous version."
          logger.log Capistrano::Logger::IMPORTANT, "Restarting..."
          raise
        ensure
          execute_tasks(*startup_steps)
        end
      end
    end
  end

end
