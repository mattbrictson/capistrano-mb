fiftyfive_recipe :logrotate do
  during :provision, "fiftyfive:logrotate"
end

namespace :fiftyfive do
  desc "Configure logrotate for Rails logs"
  task :logrotate do
    privileged_on roles(:all) do
      template "logrotate.erb",
               "/etc/logrotate.d/#{application_basename}-logs",
               :mode => 644,
               :owner => "root:root"
    end
  end
end
