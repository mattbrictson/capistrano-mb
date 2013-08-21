require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:ufw) do
  after "deploy:install", "fiftyfive:ufw:install"
  after "deploy:setup",   "fiftyfive:ufw:setup"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do

    set_default(:ufw_roles, [:web])

    namespace :ufw do
      desc "Install the latest ufw package"
      task :install, :roles => lambda { ufw_roles } do
        install_package("ufw")
      end

      desc "Setup ufw firewall rules"
      task :setup, :roles => lambda { ufw_roles } do
        stop
        run "#{sudo} ufw default deny"
        %w(ssh http https).each { |svc| run "#{sudo} ufw allow #{svc}" }
        start
      end

      desc "Start ufw"
      task :start, :roles => lambda { ufw_roles } do
        run "yes | #{sudo} ufw enable"
      end

      desc "Stop ufw"
      task :stop, :roles => lambda { ufw_roles } do
        run "#{sudo} ufw disable"
      end
    end
  end

end
