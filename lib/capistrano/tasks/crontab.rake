fiftyfive_recipe :crontab do
  during :provision, "fiftyfive:crontab"
end

namespace :fiftyfive do
  task :crontab do
    on roles(:cron) do
      tmp_file = "/tmp/crontab"
      template "crontab.erb", tmp_file
      execute "crontab #{tmp_file} && rm #{tmp_file}"
    end
  end
end
