require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:unicorn) do
  after "deploy:setup",   "fiftyfive:unicorn:setup"
  after "deploy:start",   "fiftyfive:unicorn:start"
  after "deploy:stop",    "fiftyfive:unicorn:stop"
  after "deploy:restart", "fiftyfive:unicorn:restart"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do

    set_default(:unicorn_roles, [:app])
    set_default(:unicorn_user) { user }
    set_default(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
    set_default(:unicorn_config) { "#{shared_path}/config/unicorn.rb" }
    set_default(:unicorn_log) { "#{shared_path}/log/unicorn.log" }
    set_default(:unicorn_workers, 2)
    set_default(:unicorn_timeout, 30)

    namespace :unicorn do
      desc "Setup Unicorn initializer and app configuration"
      task :setup, :roles => lambda { unicorn_roles } do
        run "mkdir -p #{shared_path}/config"

        template("unicorn.rb.erb", unicorn_config)

        template\
          "unicorn_init.erb",
          "/etc/init.d/unicorn_#{application}",
          :mode => "+x",
          :sudo => true

        run "#{sudo} update-rc.d -f unicorn_#{application} defaults"
      end

      %w[start stop restart].each do |command|
        desc "#{command} unicorn"
        task command, :roles => lambda { unicorn_roles } do
          run "service unicorn_#{application} #{command}"
        end
      end
    end
  end
end
