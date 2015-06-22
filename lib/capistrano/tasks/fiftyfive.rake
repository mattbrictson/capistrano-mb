# Provides backward compatibility with the old "fiftyfive" task names.

tasks = %w(
  fiftyfive:aptitude:change_postgres_packages
  fiftyfive:aptitude:install
  fiftyfive:aptitude:install_postgres_repo
  fiftyfive:aptitude:upgrade
  fiftyfive:crontab
  fiftyfive:delayed_job:init_d
  fiftyfive:delayed_job:restart
  fiftyfive:delayed_job:start
  fiftyfive:delayed_job:stop
  fiftyfive:dotenv:replace
  fiftyfive:dotenv:update
  fiftyfive:logrotate
  fiftyfive:maintenance:disable
  fiftyfive:maintenance:enable
  fiftyfive:migrate:deploy
  fiftyfive:nginx:configure
  fiftyfive:nginx:restart
  fiftyfive:nginx:start
  fiftyfive:nginx:stop
  fiftyfive:postgresql:create_database
  fiftyfive:postgresql:create_user
  fiftyfive:postgresql:database_yml
  fiftyfive:postgresql:dump
  fiftyfive:postgresql:logrotate_backup
  fiftyfive:postgresql:pgpass
  fiftyfive:postgresql:restore
  fiftyfive:postgresql:tune
  fiftyfive:rake
  fiftyfive:rbenv:install
  fiftyfive:rbenv:upgrade
  fiftyfive:seed
  fiftyfive:sidekiq:init_d
  fiftyfive:sidekiq:restart
  fiftyfive:sidekiq:start
  fiftyfive:sidekiq:stop
  fiftyfive:ssl:generate_csr
  fiftyfive:ssl:generate_dh
  fiftyfive:ssl:generate_self_signed_crt
  fiftyfive:ufw:configure
  fiftyfive:unicorn:config_rb
  fiftyfive:unicorn:init_d
  fiftyfive:unicorn:restart
  fiftyfive:unicorn:start
  fiftyfive:unicorn:stop
  fiftyfive:user:add
  fiftyfive:user:install_public_key
  fiftyfive:version:write_initializer
)

tasks.each do |name|
  task(name) do
    mb_name = name.gsub(/^fiftyfive:/, "mb:")
    compatibility_warning("The #{name} task has been renamed to #{mb_name}.")
    invoke(mb_name)
  end
end
