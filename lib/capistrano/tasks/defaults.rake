namespace :load do
  task :defaults do

    set :fiftyfive_recipes, %w(
      aptitude
      crontab
      dotenv
      logrotate
      migrate
      nginx
      postgresql
      rbenv
      seed
      ssl
      ufw
      unicorn
      user
      version
    )

    set :fiftyfive_privileged_user, "root"

    set :fiftyfive_aptitude_packages,
        "curl"                                   => :all,
        "debian-goodies"                         => :all,
        "git-core"                               => :all,
        "libpq-dev@ppa:pitti/postgresql"         => :all,
        "nginx@ppa:nginx/stable"                 => :web,
        "nodejs@ppa:chris-lea/node.js"           => :all,
        "postgresql-client@ppa:pitti/postgresql" => :all,
        "postgresql@ppa:pitti/postgresql"        => :db,
        "ufw"                                    => :all

    set :fiftyfive_delayed_job_args, "-n 2"
    set :fiftyfive_delayed_job_script, "bin/delayed_job"

    set :fiftyfive_dotenv_keys, %w(rails_secret_key_base postmark_api_key)
    set :fiftyfive_dotenv_filename, -> { ".env.#{fetch(:rails_env)}" }

    set :fiftyfive_log_file, "log/capistrano.log"

    set :fiftyfive_nginx_force_https, false
    set :fiftyfive_nginx_redirect_hosts, {}

    ask :fiftyfive_postgresql_password, nil, :echo => false
    set :fiftyfive_postgresql_max_connections, 25
    set :fiftyfive_postgresql_pool_size, 5
    set :fiftyfive_postgresql_host, "localhost"
    set :fiftyfive_postgresql_database,
        -> { "#{application_basename}_#{fetch(:rails_env)}" }
    set :fiftyfive_postgresql_user, -> { application_basename }
    set :fiftyfive_postgresql_pgpass_path,
        proc{ "#{shared_path}/config/pgpass" }
    set :fiftyfive_postgresql_backup_path, -> {
      "#{shared_path}/backups/postgresql-dump.dmp"
    }
    set :fiftyfive_postgresql_backup_exclude_tables, []
    set :fiftyfive_postgresql_dump_options, -> {
      options = fetch(:fiftyfive_postgresql_backup_exclude_tables).map do |t|
        "-T #{t.shellescape}"
      end
      options.join(" ")
    }

    set :fiftyfive_rbenv_ruby_version, -> { IO.read(".ruby-version").strip }
    set :fiftyfive_rbenv_vars, -> {
      {
        "RAILS_ENV" => fetch(:rails_env),
        "PGPASSFILE" => fetch(:fiftyfive_postgresql_pgpass_path)
      }
    }

    set :fiftyfive_sidekiq_concurrency, 25
    set :fiftyfive_sidekiq_role, :sidekiq

    set :fiftyfive_ssl_csr_country, "US"
    set :fiftyfive_ssl_csr_state, "California"
    set :fiftyfive_ssl_csr_city, "San Francisco"
    set :fiftyfive_ssl_csr_org, "Example Company"
    set :fiftyfive_ssl_csr_name, "example.com"

    # WARNING: misconfiguring firewall rules could lock you out of the server!
    set :fiftyfive_ufw_rules,
        "allow ssh" => :all,
        "allow http" => :web,
        "allow https" => :web

    set :fiftyfive_unicorn_workers, 2
    set :fiftyfive_unicorn_timeout, 30
    set :fiftyfive_unicorn_config, proc{ "#{current_path}/config/unicorn.rb" }
    set :fiftyfive_unicorn_log, proc{ "#{current_path}/log/unicorn.log" }
    set :fiftyfive_unicorn_pid, proc{ "#{current_path}/tmp/pids/unicorn.pid" }

    set :bundle_binstubs, false
    set :bundle_flags, '--deployment'
    set :deploy_to, -> { "/home/deployer/apps/#{fetch(:application)}" }
    set :format, :abbreviated
    set :keep_releases, 10
    set :linked_dirs, -> {
        ["public/#{fetch(:assets_prefix, 'assets')}"] +
        %w(
          log
          tmp/pids
          tmp/cache
          tmp/sockets
          public/system
        )
    }
    set :linked_files, -> {
        [fetch(:fiftyfive_dotenv_filename)] +
        %w(
          config/database.yml
          config/unicorn.rb
        )
    }
    set :log_level, :debug
    set :migration_role, :app
    set :rails_env, -> { fetch(:stage) }
    set :ssh_options, :compression => false, :keepalive => true

    SSHKit.config.command_map[:rake] = "bundle exec rake"
  end
end
