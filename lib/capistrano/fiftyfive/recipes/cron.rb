require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:cron) do
  after "deploy:setup", "fiftyfive:cron:setup"
end

Capistrano::Configuration.instance(:must_exist).load do
  namespace :fiftyfive do

    set_default(:cron_role, :cron)
    set_default(:crontab_template_path) do
      raise ":crontab_template_path must be set"
    end

    namespace :cron do
      desc "Generate and load crontab"
      task :setup, :roles => lambda { cron_role } do
        tmp_file = "/tmp/crontab"
        template(crontab_template_path, tmp_file)
        run("crontab #{tmp_file} && rm #{tmp_file}")
      end
    end
  end
end
