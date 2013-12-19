fiftyfive_recipe :secrets do
  during :provision, "create_yml"
end

namespace :fiftyfive do
  namespace :secrets do
    task :create_yml do
      keys = fetch(:fiftyfive_secrets_keys)
      keys.each { |k| ask_secretly(k) && fetch(k) }

      on release_roles(:all) do
        secrets = keys.each_with_object({}) do |key, h|
          h[key.to_s] = fetch(key)
        end

        hash = { fetch(:rails_env).to_s => secrets }
        put hash.to_yaml, "#{shared_path}/config/secrets.yml", :mode => "600"
      end
    end
  end
end
