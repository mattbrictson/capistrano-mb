namespace :load do
  task :defaults do

    set :mb_recipes, %w(
      aptitude
      bundler
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

    set :mb_privileged_user, "root"

    set :mb_aptitude_packages,
        "build-essential"        => :all,
        "curl"                   => :all,
        "debian-goodies"         => :all,
        "git-core"               => :all,
        "libpq-dev"              => :all,
        "libreadline-gplv2-dev"  => :all,
        "libssl-dev"             => :all,
        "libxml2"                => :all,
        "libxml2-dev"            => :all,
        "libxslt1-dev"           => :all,
        "nginx@ppa:nginx/stable" => :web,
        "nodejs"                 => :all,
        "ntp"                    => :all,
        "postgresql"             => :db,
        "postgresql-client"      => :all,
        "tklib"                  => :all,
        "ufw"                    => :all,
        "zlib1g-dev"             => :all

    set :mb_bundler_lockfile, "Gemfile.lock"
    set :mb_bundler_gem_install_command,
        "gem install bundler --conservative --no-document"

    set :mb_dotenv_keys, %w(rails_secret_key_base postmark_api_key)
    set :mb_dotenv_filename, -> { ".env.#{fetch(:rails_env)}" }

    set :mb_log_file, "log/capistrano.log"

    set :mb_nginx_force_https, false
    set :mb_nginx_redirect_hosts, {}

    ask :mb_postgresql_password, nil, :echo => false
    set :mb_postgresql_pool_size, 5
    set :mb_postgresql_host, "localhost"
    set :mb_postgresql_database,
        -> { "#{application_basename}_#{fetch(:rails_env)}" }
    set :mb_postgresql_user, -> { application_basename }
    set :mb_postgresql_pgpass_path,
        proc{ "#{shared_path}/config/pgpass" }
    set :mb_postgresql_backup_path, -> {
      "#{shared_path}/backups/postgresql-dump.dmp"
    }
    set :mb_postgresql_backup_exclude_tables, []
    set :mb_postgresql_dump_options, -> {
      options = fetch(:mb_postgresql_backup_exclude_tables).map do |t|
        "-T #{t.shellescape}"
      end
      options.join(" ")
    }

    set :mb_rbenv_ruby_version, -> { IO.read(".ruby-version").strip }
    set :mb_rbenv_vars, -> {
      {
        "RAILS_ENV" => fetch(:rails_env),
        "PGPASSFILE" => fetch(:mb_postgresql_pgpass_path)
      }
    }

    set :mb_sidekiq_concurrency, 25
    set :mb_sidekiq_role, :sidekiq

    ask :mb_ssl_csr_country, "US"
    ask :mb_ssl_csr_state, "California"
    ask :mb_ssl_csr_city, "San Francisco"
    ask :mb_ssl_csr_org, "Example Company"
    ask :mb_ssl_csr_name, "www.example.com"

    # WARNING: misconfiguring firewall rules could lock you out of the server!
    set :mb_ufw_rules,
        "allow ssh" => :all,
        "allow http" => :web,
        "allow https" => :web

    set :mb_unicorn_workers, 2
    set :mb_unicorn_timeout, 30
    set :mb_unicorn_config, proc{ "#{current_path}/config/unicorn.rb" }
    set :mb_unicorn_log, proc{ "#{current_path}/log/unicorn.log" }
    set :mb_unicorn_pid, proc{ "#{current_path}/tmp/pids/unicorn.pid" }

    set :bundle_binstubs, false
    set :bundle_flags, "--deployment --retry=3 --quiet"
    set :bundle_path, -> { shared_path.join("bundle") }
    set :deploy_to, -> { "/home/deployer/apps/#{fetch(:application)}" }
    set :keep_releases, 10
    set :linked_dirs, -> {
        ["public/#{fetch(:assets_prefix, 'assets')}"] +
        %w(
          .bundle
          log
          tmp/pids
          tmp/cache
          tmp/sockets
          public/.well-known
          public/system
        )
    }
    set :linked_files, -> {
        [fetch(:mb_dotenv_filename)] +
        %w(
          config/database.yml
          config/unicorn.rb
        )
    }
    set :log_level, :debug
    set :migration_role, :app
    set :rails_env, -> { fetch(:stage) }
    set :ssh_options, :compression => true, :keepalive => true

    SSHKit.config.command_map[:rake] = "bundle exec rake"
  end
end
