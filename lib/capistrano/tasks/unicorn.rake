mb_recipe :unicorn do
  during :provision, %w(systemd config_rb)
  during "deploy:start", "start"
  during "deploy:stop", "stop"
  during "deploy:restart", "restart"
  during "deploy:publishing", "restart"
end

namespace :mb do
  namespace :unicorn do
    desc "Install unicorn systemd config"
    task :systemd do
      privileged_on roles(:app) do |host, user|
        unicorn_user = fetch(:mb_unicorn_user) || user

        template "unicorn.service.erb",
                 "/etc/systemd/system/unicorn_#{application_basename}.service",
                 :mode => "a+rx",
                 :binding => binding,
                 :sudo => true

        execute :sudo, "systemctl daemon-reload"
        execute :sudo, "systemctl enable unicorn_#{application_basename}.service"

        unless test(:sudo, "grep -qs unicorn_#{application_basename}.service /etc/sudoers.d/#{user}")
          execute :sudo, "touch -f /etc/sudoers.d/#{user}"
          execute :sudo, "chmod u+w /etc/sudoers.d/#{user}"
          execute :sudo, "echo '#{user} ALL=NOPASSWD: /bin/systemctl start unicorn_#{application_basename}.service' >> /etc/sudoers.d/#{user}"
          execute :sudo, "echo '#{user} ALL=NOPASSWD: /bin/systemctl stop unicorn_#{application_basename}.service' >> /etc/sudoers.d/#{user}"
          execute :sudo, "echo '#{user} ALL=NOPASSWD: /bin/systemctl restart unicorn_#{application_basename}.service' >> /etc/sudoers.d/#{user}"
          execute :sudo, "chmod 440 /etc/sudoers.d/#{user}"
        end
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
          execute :sudo, "systemctl #{command} unicorn_#{application_basename}.service"
        end
      end
    end
  end
end
