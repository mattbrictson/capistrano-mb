mb_recipe :bundler do
  prior_to "bundler:install", "gem_install"
end

namespace :mb do
  namespace :bundler do
    desc "Install correct version of bundler based on Gemfile.lock"
    task :gem_install do
      install_command = fetch(:mb_bundler_gem_install_command, nil)
      next unless install_command

      on fetch(:bundle_servers) do
        within release_path do
          if (bundled_with = capture_bundled_with)
            execute "#{install_command} -v #{bundled_with}"
          end
        end
      end
    end

    def capture_bundled_with
      lockfile = fetch(:mb_bundler_lockfile, "Gemfile.lock")
      return unless test "[ -f #{release_path.join(lockfile)} ]"

      ruby_expr = 'puts $<.read[/BUNDLED WITH\n   (\S+)$/, 1]'
      version = capture :ruby, "-e", ruby_expr.shellescape, lockfile
      version.strip!
      version.empty? ? nil : version
    end
  end
end
