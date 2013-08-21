require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:delayed_job) do
  after "deploy:setup",   "fiftyfive:delayed_job:setup"
  after "deploy:start",   "fiftyfive:delayed_job:start"
  after "deploy:stop",    "fiftyfive:delayed_job:stop"
  after "deploy:restart", "fiftyfive:delayed_job:restart"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do

    set_default(:delayed_job_role, :delayed_job)
    set_default(:delayed_job_args, "")
    set_default(:delayed_job_user) { user }

    namespace :delayed_job do
      desc "Install delayed_job service script"
      task :setup, :roles => lambda { delayed_job_role } do
        template\
          "delayed_job_init.erb",
          "/etc/init.d/delayed_job_#{application}",
          :mode => "+x",
          :sudo => true

        run "#{sudo} update-rc.d -f delayed_job_#{application} defaults"
      end

      %w[start stop restart].each do |command|
        desc "#{command} delayed_job"
        task command, :roles => lambda { delayed_job_role } do
          run "service delayed_job_#{application} #{command}"
        end
      end
    end

  end
end
