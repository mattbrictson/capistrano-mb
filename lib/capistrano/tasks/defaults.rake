namespace :load do
  task :defaults do

    set :fiftyfive_recipes, %w(
      aptitude
      crontab
      logrotate
      migrate
      nginx
      postgresql
      rbenv
      secrets
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
        "nodejs@ppa:chris-lea/node.js"           => :web,
        "postgresql-client@ppa:pitti/postgresql" => :all,
        "postgresql@ppa:pitti/postgresql"        => :db,
        "ufw"                                    => :all

    set :fiftyfive_delayed_job_args, "-n 2"
    set :fiftyfive_delayed_job_script, "bin/delayed_job"

    set :fiftyfive_nginx_force_https, false
    set :fiftyfive_nginx_redirect_hosts, {}

    ask_secretly :fiftyfive_postgresql_password
    set :fiftyfive_postgresql_max_connections, 25
    set :fiftyfive_postgresql_pool_size, 5
    set :fiftyfive_postgresql_host, "localhost"
    set :fiftyfive_postgresql_database,
        proc { "#{application_basename}_#{fetch(:rails_env)}" }
    set :fiftyfive_postgresql_user, proc { application_basename }
    set :fiftyfive_postgresql_pgpass_path,
        proc{ "#{shared_path}/config/pgpass" }
    set :fiftyfive_postgresql_backup_path, proc {
      "#{shared_path}/backups/postgresql-dump.dmp"
    }
    set :fiftyfive_postgresql_backup_exclude_tables, []
    set :fiftyfive_postgresql_dump_options, proc {
      options = fetch(:fiftyfive_postgresql_backup_exclude_tables).map do |t|
        "-T #{t.shellescape}"
      end
      options.join(" ")
    }

    set :fiftyfive_rbenv_ruby_version, proc { IO.read(".ruby-version").strip }
    set :fiftyfive_rbenv_vars, proc {
      {
        "RAILS_ENV" => fetch(:rails_env),
        "PGPASSFILE" => fetch(:fiftyfive_postgresql_pgpass_path)
      }
    }

    set :fiftyfive_secrets_keys, %w(rails_secret_key_base postmark_api_key)

    set :fiftyfive_sidekiq_concurrency, 25
    set :fiftyfive_sidekiq_role, :sidekiq

    set :fiftyfive_ssl_csr_country, "US"
    set :fiftyfive_ssl_csr_state, "California"
    set :fiftyfive_ssl_csr_city, "Albany"
    set :fiftyfive_ssl_csr_org, "55 Minutes, Inc."
    set :fiftyfive_ssl_csr_name, "example.55minutes.com"

    set :fiftyfive_ufw_rules,
        "allow ssh" => :all,
        "allow http" => :web,
        "allow https" => :web

    set :fiftyfive_unicorn_workers, 2
    set :fiftyfive_unicorn_timeout, 30
    set :fiftyfive_unicorn_config, proc{ "#{current_path}/config/unicorn.rb" }
    set :fiftyfive_unicorn_log, proc{ "#{current_path}/log/unicorn.log" }
    set :fiftyfive_unicorn_pid, proc{ "#{current_path}/tmp/pids/unicorn.pid" }

    set :bundle_flags, '--deployment --quiet -j4'
    set :deploy_to, proc { "/home/deployer/apps/#{fetch(:application)}" }
    set :keep_releases, 10
    set :format, :pretty
    set :linked_dirs, -> {
        ["public/#{fetch(:assets_prefix, 'assets')}"] +
        %w(
          bin
          log
          tmp/pids
          tmp/cache
          tmp/sockets
          public/system
        )
    }
    set :linked_files, %w(
      config/database.yml
      config/secrets.yml
      config/unicorn.rb
    )
    set :log_level, :info
    set :migration_role, :app
    set :rails_env, proc { fetch(:stage) }
    set :ssh_options, :compression => false

    SSHKit.config.command_map[:rake] = "bundle exec rake"
  end
end
