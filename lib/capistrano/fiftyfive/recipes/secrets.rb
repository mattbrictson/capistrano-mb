require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:secrets) do
  after "deploy:setup",           "fiftyfive:secrets:setup"
  after "deploy:finalize_update", "fiftyfive:secrets:symlink"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do

    set_default(:secrets_roles, [:app, :db, :delayed_job])
    set_default(:secret_keys) { %w(rails_secret_token postmark_api_key) }

    namespace :secrets do
      desc "Generate the secrets.yml configuration file."
      task :setup, :roles => lambda { secrets_roles } do
        secrets = {}

        secret_keys.each do |k|
          value = Capistrano::CLI.password_prompt "#{rails_env.capitalize} #{k}: "
          secrets[k.to_s] = value.to_s
        end

        run "mkdir -p #{shared_path}/config"

        hash = { rails_env => secrets }
        put(hash.to_yaml, "#{shared_path}/config/secrets.yml", :mode => "600")
      end

      desc "Symlink the secrets.yml file into latest release"
      task :symlink, :roles => lambda { secrets_roles } do
        run "rm -f #{release_path}/config/secrets.yml"
        run "ln -nfs #{shared_path}/config/secrets.yml #{release_path}/config/secrets.yml"
      end
    end
  end

end
