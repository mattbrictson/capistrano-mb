mb_recipe :rbenv do
  during :provision, %w(install write_vars)
end

namespace :mb do
  namespace :rbenv do
    desc "Install rbenv and compile ruby"
    task :install do
      invoke "mb:rbenv:run_installer"
      invoke "mb:rbenv:add_plugins"
      invoke "mb:rbenv:modify_bashrc"
      invoke "mb:rbenv:compile_ruby"
    end

    desc "Install the latest version of Ruby"
    task :upgrade do
      invoke "mb:rbenv:add_plugins"
      invoke "mb:rbenv:update_rbenv"
      invoke "mb:rbenv:compile_ruby"
    end

    task :write_vars do
      on release_roles(:all) do
        execute :mkdir, "-p ~/.rbenv"
        execute :touch, "~/.rbenv/vars"
        execute :chmod, "0600 ~/.rbenv/vars"

        vars = ""

        fetch(:mb_rbenv_vars).each do |name, value|
          execute :sed, "--in-place '/^#{name}=/d' ~/.rbenv/vars"
          vars << "#{name}=#{value}\n"
        end

        tmp_file = "/tmp/rbenv_vars"
        put vars, tmp_file
        execute :cat, tmp_file, ">> ~/.rbenv/vars"
        execute :rm, tmp_file
      end
    end

    task :run_installer do
      installer_url = \
      "https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer"

      on release_roles(:all) do
        with :path => "$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH" do
          execute :curl, "-fsSL", installer_url, "| bash"
        end
      end
    end

    task :add_plugins do
      plugins = %w(
        sstephenson/rbenv-vars
        sstephenson/ruby-build
        rkh/rbenv-update
      )
      plugins.each do |plugin|
        git_repo = "https://github.com/#{plugin}.git"
        plugin_dir = "$HOME/.rbenv/plugins/#{plugin.split('/').last}"

        on release_roles(:all) do
          unless test("[ -d #{plugin_dir} ]")
            execute :git, "clone", git_repo, plugin_dir
          end
        end
      end
    end

    task :modify_bashrc do
      on release_roles(:all) do
        unless test("grep -qs 'rbenv init' ~/.bashrc")
          template("rbenv_bashrc", "/tmp/rbenvrc")
          execute :cat, "/tmp/rbenvrc ~/.bashrc > /tmp/bashrc"
          execute :mv, "/tmp/bashrc ~/.bashrc"
        end
      end
    end

    task :compile_ruby do
      ruby_version = fetch(:mb_rbenv_ruby_version)
      on release_roles(:all) do
        force = ENV["RBENV_FORCE_INSTALL"] || begin
          ! test("rbenv versions | grep -q '#{ruby_version}'")
        end

        if force
          execute "CFLAGS=-O3 rbenv install --force #{ruby_version}"
          execute "rbenv global #{ruby_version}"
          execute "gem install bundler --no-document"
        end
      end
    end

    task :update_rbenv do
      on release_roles(:all) do
        execute "rbenv update"
      end
    end
  end
end
