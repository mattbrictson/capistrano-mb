require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:seeds) do
  after "deploy:migrate", "fiftyfive:seeds:execute"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do
    namespace :seeds do
      desc "Run rake db:seed"
      task :execute, :roles => :app, :once => true do
        run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} db:seed"
      end
    end
  end

end
