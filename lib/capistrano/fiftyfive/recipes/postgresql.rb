require "capistrano/fiftyfive"

Capistrano::Fiftyfive.register_hooks(:postgresql) do
  after "deploy:install",         "fiftyfive:postgresql:install_server"
  after "deploy:install",         "fiftyfive:postgresql:install_client"
  after "deploy:setup",           "fiftyfive:postgresql:create_database"
  after "deploy:setup",           "fiftyfive:postgresql:setup_database_yml"
  after "deploy:setup",           "fiftyfive:postgresql:setup_pgpass"
  after "deploy:setup",           "fiftyfive:postgresql:setup_backup"
  after "deploy:finalize_update", "fiftyfive:postgresql:symlink"
end

Capistrano::Configuration.instance(:must_exist).load do

  namespace :fiftyfive do

    set_default(:postgresql_host, "localhost")
    set_default(:postgresql_client_roles, [:app, :worker])
    set_default(:postgresql_backup_role, [:backup])
    set_default(:postgresql_user) { application.gsub('-', '_') }
    set_default(:postgresql_pgpass_path) { "#{shared_path}/config/pgpass" }
    set_default(:postgresql_backup_exclude_tables, [])

    set_default(:postgresql_password) do
      Capistrano::CLI.password_prompt "PostgreSQL Password: "
    end

    set_default(:postgresql_database) do
      "#{application}_#{rails_env}".gsub('-', '_')
    end

    set_default(:postgresql_backup_path) do
      "#{shared_path}/backups/postgresql-dump.dmp"
    end

    set_default(:postgresql_dump_options) do
      options = postgresql_backup_exclude_tables.map do |table|
        "-T #{table.shellescape}"
      end
      options.join(" ")
    end

    namespace :postgresql do
      desc "Install the latest stable release of PostgreSQL server."
      task :install_server, :roles => :db do
        add_package_repository("ppa:pitti/postgresql")
        install_packages("postgresql", "libpq-dev")
      end

      desc "Install the latest stable release of PostgreSQL client."
      task :install_client, :roles => lambda { postgresql_client_roles } do
        add_package_repository("ppa:pitti/postgresql")

        install_package("postgresql-client")
        install_package("libpq-dev")
      end

      desc "Create a database for this application."
      task :create_database, :roles => :db, :only => { :primary => true } do
        tmp_script = "/tmp/pg_create"
        template("postgresql_create_db.erb", tmp_script)
        run "#{sudo} -u postgres bash -e #{tmp_script}"
        run "rm #{tmp_script}"
      end

      desc "Generate the database.yml configuration file."
      task :setup_database_yml, :roles => lambda { postgresql_client_roles } do
        run "mkdir -p #{shared_path}/config"

        template "postgresql.yml.erb",
                 "#{shared_path}/config/database.yml",
                 :mode => "600"
      end

      desc "Generate the pgpass configuration file."
      task :setup_pgpass, :roles => lambda { postgresql_client_roles } do
        pgpass_dir = File.dirname(postgresql_pgpass_path)
        run "mkdir -p #{pgpass_dir}"

        template("pgpass.erb", postgresql_pgpass_path, :mode => "600")
        write_rbenv_var("PGPASSFILE", postgresql_pgpass_path)
      end

      desc "Generate logrotated configuration for performing backups."
      task :setup_backup, :roles => postgresql_backup_role do
        run "mkdir -p #{File.dirname(postgresql_backup_path)}"

        template\
          "postgresql-backup-logrotate.erb",
          "/etc/logrotate.d/postgresql-backup-#{application}",
          :sudo => true,
          :owner => "root:root",
          :mode => "644"

        run "touch #{postgresql_backup_path}"
      end

      desc "Symlink the database.yml file into latest release"
      task :symlink, :roles => lambda { postgresql_client_roles } do
        run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      end
    end

  end
end
