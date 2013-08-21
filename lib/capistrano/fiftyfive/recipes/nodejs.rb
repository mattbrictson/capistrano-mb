require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:nodejs) do
  after "deploy:install", "fiftyfive:nodejs:install"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do
    namespace :nodejs do
      desc "Install the latest relase of Node.js"
      task :install, :roles => :web do
        add_package_repository("ppa:chris-lea/node.js")
        install_package("nodejs")
      end
    end
  end

end
