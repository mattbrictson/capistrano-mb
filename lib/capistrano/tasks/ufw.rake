fiftyfive_recipe :ufw do
  during :provision, "configure"
end

namespace :fiftyfive do
  namespace :ufw do
    desc "Configure role-based ufw rules on each server"
    task :configure do
      rules = fetch(:fiftyfive_ufw_rules, {})
      distinct_roles = rules.values.flatten.uniq

      # First reset the firewall on all affected servers
      privileged_on roles(*distinct_roles) do
        execute "ufw --force reset"
        execute "ufw default deny incoming"
        execute "ufw default allow outgoing"
      end

      # Then set up all ufw rules according to the fiftyfive_ufw_rules hash
      rules.each do |command, *role_names|
        privileged_on roles(*role_names.flatten) do
          execute "ufw #{command}"
        end
      end

      # Finally, enable the firewall on all affected servers
      privileged_on roles(*distinct_roles) do
        execute "ufw --force enable"
      end
    end
  end
end
