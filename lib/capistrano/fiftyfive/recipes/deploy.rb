require "capistrano/fiftyfive"

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do
    namespace :deploy do
      desc "Deploy code, put app into maintenance mode, migrate, and restart"
      task :migrate_and_restart do
        steps = %w(
          deploy:update
          deploy:web:disable
          deploy:stop
          deploy:migrate
          deploy:start
          deploy:web:enable
        )
        steps.each { |s| find_and_execute_task(s) }
      end
    end
  end

end
