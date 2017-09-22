mb_recipe :sidekiq do
  during :provision, "systemd"
  during "deploy:start", "start"
  during "deploy:stop", "stop"
  during "deploy:restart", "restart"
  during "deploy:publishing", "restart"
end

namespace :mb do
  namespace :sidekiq do
    desc "Install sidekiq systemd config"
    task :systemd do
      privileged_on roles(fetch(:mb_sidekiq_role)) do |host, user|
        sidekiq_user = fetch(:mb_sidekiq_user) || user

        template "sidekiq.service.erb",
                 "/etc/systemd/system/sidekiq_#{application_basename}.service",
                 :mode => "a+rx",
                 :binding => binding,
                 :sudo => true

        execute :sudo, "systemctl daemon-reload"
        execute :sudo, "systemctl enable sidekiq_#{application_basename}.service"

        unless test(:sudo, "grep -qs sidekiq_#{application_basename}.service /etc/sudoers.d/#{user}")
          execute :sudo, "touch -f /etc/sudoers.d/#{user}"
          execute :sudo, "chmod u+w /etc/sudoers.d/#{user}"
          execute :sudo, "echo '#{user} ALL=NOPASSWD: /bin/systemctl start sidekiq_#{application_basename}.service' >> /etc/sudoers.d/#{user}"
          execute :sudo, "echo '#{user} ALL=NOPASSWD: /bin/systemctl stop sidekiq_#{application_basename}.service' >> /etc/sudoers.d/#{user}"
          execute :sudo, "echo '#{user} ALL=NOPASSWD: /bin/systemctl restart sidekiq_#{application_basename}.service' >> /etc/sudoers.d/#{user}"
          execute :sudo, "chmod 440 /etc/sudoers.d/#{user}"
        end
      end
    end

    %w[start stop restart].each do |command|
      desc "#{command} sidekiq"
      task command do
        on roles(fetch(:mb_sidekiq_role)) do
          execute :sudo, "systemctl #{command} sidekiq_#{application_basename}.service"
        end
      end
    end
  end
end
