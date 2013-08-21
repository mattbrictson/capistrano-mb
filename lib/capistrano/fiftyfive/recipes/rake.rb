require "capistrano/fiftyfive"

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do
    namespace :rake_task do
      desc "Execute rake COMMAND once on first matching app server"
      task :invoke, :roles => :app, :once => true do
        if ENV['COMMAND'].nil?
          raise "USAGE: cap fiftyfive:rake_task:invoke COMMAND='db:migrate'"
        end

        run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{ENV['COMMAND']}"
      end
    end
  end
end
