require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:rbenv) do
  after "deploy:install",      "fiftyfive:rbenv:install"
  after "deploy:setup",        "fiftyfive:rbenv:setup"
  before "deploy:update_code", "fiftyfive:rbenv:check"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do

    set_default(:project_root) { raise "You must set :project_root" }
    set_default(:ruby_version) do
      File.read(File.join(project_root, ".ruby-version")).strip
    end

    namespace :rbenv do
      desc "Install rbenv, Ruby, and the Bundler gem"
      task :install do
        install_packages("curl", "git-core")

        install_rbenv
        modify_bashrc
        bootstrap_ubuntu_for_ruby_compile
        compile_ruby
      end

      desc "Set up standard variables for rbenv"
      task :setup do
        write_rbenv_var("RAILS_ENV", rails_env)
      end

      desc "Install the latest version of Ruby"
      task :upgrade do
        update_rbenv
        bootstrap_ubuntu_for_ruby_compile
        compile_ruby
      end

      desc "Update just rbenv and its plugins, without compiling Ruby"
      task :update do
        update_rbenv
      end

      desc "Check that the specified version of Ruby is properly installed"
      task :check do
        begin
          run("rbenv versions | grep '#{ruby_version}'")
        rescue Capistrano::CommandError
          logger.log(Capistrano::Logger::IMPORTANT, "Required Ruby version is not installed: #{ruby_version}")
          logger.log(Capistrano::Logger::IMPORTANT, "Run rbenv:upgrade to install it")
          exit(1)
        end
      end

      task :install_rbenv do
        run "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
      end

      task :update_rbenv do
        run "rbenv update"
      end

      task :modify_bashrc do
        bashrc = <<-BASHRC
if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi
BASHRC
        put bashrc, "/tmp/rbenvrc"
        run "cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp"

        # Only replace ~/.bashrc if it doesn't already contain "rbenv init"
        run "grep -qs 'rbenv init' ~/.bashrc || mv ~/.bashrc.tmp ~/.bashrc"

        # Load rbenv into the current shell
        run %q{export PATH="$HOME/.rbenv/bin:$PATH"}
        run %q{eval "$(rbenv init -)"}
      end

      task :bootstrap_ubuntu_for_ruby_compile do
        run "#{sudo} $HOME/.rbenv/plugins/rbenv-bootstrap/bin/rbenv-bootstrap-ubuntu-12-04"
      end

      task :compile_ruby do
        run "rbenv versions | grep -q '#{ruby_version}' || CFLAGS=-O3 rbenv install #{ruby_version}"
        run "rbenv global #{ruby_version}"
        run "gem install bundler --no-ri --no-rdoc"
        run "rbenv rehash"
      end

    end
  end
end
