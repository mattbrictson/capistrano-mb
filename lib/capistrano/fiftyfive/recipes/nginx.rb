require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:nginx) do
  after "deploy:install", "fiftyfive:nginx:install"
  after "deploy:setup",   "fiftyfive:nginx:setup"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do

    set_default(:nginx_force_https, false)
    set_default(:nginx_redirect_hosts, Hash.new)

    namespace :nginx do
      desc "Install latest stable release of nginx"
      task :install, :roles => :web do
        add_package_repository("ppa:nginx/stable")
        install_package("nginx")
      end

      desc "Setup nginx configuration for this application"
      task :setup, :roles => :web do
        template("nginx.erb", "/etc/nginx/nginx.conf", :sudo => true)

        template\
          "nginx_unicorn.erb",
          "/etc/nginx/sites-enabled/#{application}",
          :sudo => true

        run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
        run "#{sudo} mkdir -p /etc/nginx/#{application}-locations"

        restart
      end

      %w[start stop restart].each do |command|
        desc "#{command} nginx"
        task command, :roles => :web do
          run "#{sudo} service nginx #{command}"
        end
      end
    end
  end

end
