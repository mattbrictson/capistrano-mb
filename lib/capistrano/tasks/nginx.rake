fiftyfive_recipe :nginx do
  during :provision, "configure"
end

namespace :fiftyfive do
  namespace :nginx do
    desc "Install nginx.conf files and restart nginx"
    task :configure do
      privileged_on roles(:web) do
        template("nginx.erb", "/etc/nginx/nginx.conf", :sudo => true)

        template "nginx_unicorn.erb",
                 "/etc/nginx/sites-enabled/#{application_basename}",
                 :sudo => true

        execute "sudo rm -f /etc/nginx/sites-enabled/default"
        execute "sudo mkdir -p /etc/nginx/#{application_basename}-locations"
        execute "sudo service nginx restart"
      end
    end

    %w(start stop restart).each do |command|
      desc "#{command} nginx"
      task command.intern do
        privileged_on roles(:web) do
          execute "sudo service nginx #{command}"
        end
      end
    end
  end
end
