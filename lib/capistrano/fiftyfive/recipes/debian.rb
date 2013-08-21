require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:debian) do
  after "deploy:install", "fiftyfive:debian:install_goodies"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do
    namespace :debian do
      desc "Install the debain-goodies package"
      task :install_goodies do
        install_package("debian-goodies")
      end
    end
  end

end
