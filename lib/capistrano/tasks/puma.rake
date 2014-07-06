fiftyfive_recipe :puma do
  during "deploy:starting", "starting"
  during :provision, %w(init_d nginx_site config_rb)
  during "deploy:start", "start"
  during "deploy:stop", "stop"
  during "deploy:restart", "restart"
  during "deploy:publishing", "restart"
end

namespace :fiftyfive do
  namespace :puma do
    task :starting do
      fetch(:linked_files, []) << "config/puma.rb"
    end

    desc "Install service script for puma"
    task :init_d do
      privileged_on roles(:app) do |host, user|
        puma_user = fetch(:fiftyfive_puma_user) || user

        template "puma_init.erb",
                 "/etc/init.d/puma_#{application_basename}",
                 :mode => "a+rx",
                 :binding => binding

        execute "update-rc.d -f puma_#{application_basename} defaults"
      end
    end

    desc "Install puma proxy into nginx sites and restart nginx"
    task :nginx_site do
      set(:fiftyfive_server_name, "puma")

      privileged_on roles(:web) do
        template "nginx_site.erb",
                 "/etc/nginx/sites-enabled/#{application_basename}"
        execute "rm -f /etc/nginx/sites-enabled/default"
        execute "mkdir -p /etc/nginx/#{application_basename}-locations"
        execute "service nginx restart"
      end
    end

    desc "Create config/puma.rb"
    task :config_rb do
      on release_roles(:all) do
        template "puma.rb.erb", "#{shared_path}/config/puma.rb"
      end
    end

    %w[start stop].each do |command|
      desc "#{command} puma"
      task command do
        on roles(:app) do
          execute "service puma_#{application_basename} #{command}"
        end
      end
    end

    desc "restart puma"
    task :restart do
      on roles(:app) do
        execute "service puma_#{application_basename} restart || "\
                "service puma_#{application_basename} start"
      end
    end
  end
end
