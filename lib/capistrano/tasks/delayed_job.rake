fiftyfive_recipe :delayed_job do
  during :provision, "init_d"
  during "deploy:start", "start"
  during "deploy:stop", "stop"
  during "deploy:restart", "restart"
  during "deploy:publishing", "restart" unless deploy_includes_restart?
end

namespace :fiftyfive do
  namespace :delayed_job do
    desc "Install delayed_job service script"
    task :init_d do
      privileged_on roles(:delayed_job) do |host, user|
        template "delayed_job_init.erb",
                 "/etc/init.d/delayed_job_#{application_basename}",
                 :mode => "a+rx",
                 :binding => binding

        execute "update-rc.d -f delayed_job_#{application_basename} defaults"
      end
    end

    %w[start stop restart].each do |command|
      desc "#{command} delayed_job"
      task command do
        on roles(:delayed_job) do
          execute "service delayed_job_#{application_basename} #{command}"
        end
      end
    end
  end
end
