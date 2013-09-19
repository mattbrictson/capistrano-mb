require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:dotenv) do
  after "deploy:setup", "fiftyfive:dotenv:setup"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do

    set_default(:dotenv_roles, [:app, :db, :delayed_job])
    set_default(:dotenv_keys) { %w(RAILS_SECRET_KEY_BASE POSTMARK_API_KEY) }

    namespace :dotenv do
      desc "Generate the .env configuration file."
      task :setup, :roles => lambda { dotenv_roles } do
        unless dotenv_keys.empty?
          logger.log Capistrano::Logger::IMPORTANT,
                     "Please specify config for the #{rails_env.to_s.upcase} "\
                     "environment."
        end

        env_text = dotenv_keys.each_with_object("") do |k, text|
          value = Capistrano::CLI.password_prompt("#{k}= ")
          text << "#{k}=#{value}\n"
        end

        run "mkdir -p #{File.dirname(dotenv_path)}"
        put(env_text, dotenv_path, :mode => "600")
      end
    end
  end

end
