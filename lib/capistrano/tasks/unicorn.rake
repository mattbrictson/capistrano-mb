fiftyfive_recipe :unicorn do
  during :provision, %w(init_d config_rb)
  during "deploy:start", "start"
  during "deploy:stop", "stop"
  during "deploy:restart", "restart"
  during "deploy:publishing", "restart" unless deploy_includes_restart?
end

namespace :fiftyfive do
  namespace :unicorn do
    task :init_d do
      privileged_on roles(:app) do |host, user|
        unicorn_user = fetch(:fiftyfive_unicorn_user) || user

        template "unicorn_init.erb",
                 "/etc/init.d/unicorn_#{application_basename}",
                 :mode => "a+rx",
                 :binding => binding

        execute "update-rc.d -f unicorn_#{application_basename} defaults"
      end
    end

    task :config_rb do
      on roles(:app) do
        template "unicorn.rb.erb", "#{shared_path}/config/unicorn.rb"
      end
    end

    %w[start stop restart].each do |command|
      task command do
        on roles(:app) do
          execute "service unicorn_#{application_basename} #{command}"
        end
      end
    end
  end
end
