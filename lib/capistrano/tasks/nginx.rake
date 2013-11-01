fiftyfive_recipe :nginx do
  during :provision, "configure"
end

namespace :fiftyfive do
  namespace :nginx do
    task :configure do
      privileged_on roles(:web) do
        template("nginx.erb", "/etc/nginx/nginx.conf")

        template "nginx_unicorn.erb",
                 "/etc/nginx/sites-enabled/#{application_basename}"

        execute "rm -f /etc/nginx/sites-enabled/default"
        execute "mkdir -p /etc/nginx/#{application_basename}-locations"
        execute "service nginx restart"
      end
    end

    %w(start stop restart).each do |command|
      task command.intern do
        privileged_on roles(:web) do
          execute "service nginx #{command}"
        end
      end
    end
  end
end
