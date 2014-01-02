fiftyfive_recipe :ufw do
  during :provision, "configure"
end

namespace :fiftyfive do
  namespace :ufw do
    desc "Configure role-based ufw rules on each server"
    task :configure do
      fetch(:fiftyfive_ufw_rules).each do |command, *role_names|
        privileged_on roles(*role_names.flatten) do
          execute "ufw disable"
          execute "ufw default deny"
          execute "ufw #{command}"
          execute "yes | ufw enable"
        end
      end
    end
  end
end
