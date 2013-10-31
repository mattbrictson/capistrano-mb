require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:ufw) do
  after "deploy:install", "fiftyfive:ufw:install"
  after "deploy:setup",   "fiftyfive:ufw:allow_ssh"
  after "deploy:setup",   "fiftyfive:ufw:allow_http"
  after "deploy:setup",   "fiftyfive:ufw:allow_postgresql"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do

    set_default(:ufw_ssh_roles) { roles.keys }
    set_default(:ufw_allow_postgresql_connections_from_hosts, [])

    namespace :ufw do

      def default_deny_and(*commands)
        execute_task("fiftyfive:ufw:stop")
        run "#{sudo} ufw default deny"
        commands.each { |cmd| run "#{sudo} ufw #{cmd}" }
        execute_task("fiftyfive:ufw:start")
      end

      desc "Install the latest ufw package"
      task :install do
        install_package("ufw")
      end

      desc "Allow ssh"
      task :allow_ssh, :roles => lambda { ufw_ssh_roles } do
        default_deny_and("allow ssh")
      end

      desc "Allow http and https"
      task :allow_http, :roles => :web do
        default_deny_and("allow http", "allow https")
      end

      desc "Allow postgresql (5432)"
      task :allow_postgresql, :roles => :db do
        ufw_allow_postgresql_connections_from_hosts.each do |host|
          default_deny_and("allow from #{host} to any port 5432")
        end
      end

      desc "Start ufw"
      task :start do
        run "yes | #{sudo} ufw enable"
      end

      desc "Stop ufw"
      task :stop do
        run "#{sudo} ufw disable"
      end
    end
  end

end
