fiftyfive_recipe :unicorn do
  during :provision, %w(init_d config_rb)
  during "deploy:start", "start"
  during "deploy:stop", "stop"
  during "deploy:restart", "restart"
  during "deploy:publishing", "restart"
end

namespace :fiftyfive do
  namespace :unicorn do
    desc "Install service script for unicorn"
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

    desc "Create config/unicorn.rb"
    task :config_rb do
      on release_roles(:all) do
        template "unicorn.rb.erb", "#{shared_path}/config/unicorn.rb"
      end
    end

    %w[start stop restart].each do |command|
      desc "#{command} unicorn"
      task command do
        on roles(:app) do
          execute "service unicorn_#{application_basename} #{command}"
        end
      end
    end
  end
end
