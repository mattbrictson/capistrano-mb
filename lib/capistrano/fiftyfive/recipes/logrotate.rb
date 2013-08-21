require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:logrotate) do
  after "deploy:setup", "fiftyfive:logrotate:setup"
end

Capistrano::Configuration.instance(:must_exist).load do
  namespace :fiftyfive do
    set_default(:rails_log_glob) { "#{shared_path}/log/*.log" }

    namespace :logrotate do
      desc "Configure logrotate for Rails logs"
      task :setup do
        template "logrotate.erb",
                 "/etc/logrotate.d/#{application}-logs",
                 :sudo => true,
                 :mode => 644,
                 :owner => "root:root"
      end
    end
  end
end
