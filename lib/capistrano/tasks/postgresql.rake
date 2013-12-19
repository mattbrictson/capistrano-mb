fiftyfive_recipe :postgresql do
  during :provision, %w(
    create_user
    create_database
    database_yml
    pgpass
    logrotate_backup
  )
end

namespace :fiftyfive do
  namespace :postgresql do
    task :tune do
      privileged_on primary(:db), :in => :sequence do
        pgtune_dir = "/tmp/pgtune"
        pgtune_output = "/tmp/postgresql.conf.pgtune"
        pg_conf = "/etc/postgresql/9.1/main/postgresql.conf"

        execute :rm, "-rf", pgtune_dir
        execute :git,
                "clone",
                "-q",
                "https://github.com/gregs1104/pgtune.git",
                pgtune_dir

        execute "#{pgtune_dir}/pgtune",
                "--input-config", pg_conf,
                "--output-config", pgtune_output,
                "--type", "Web",
                "--connections", fetch(:fiftyfive_postgresql_max_connections)

        # Log diff for informational purposes
        execute :diff, pg_conf, pgtune_output, "|| true"

        execute :cp, pgtune_output, pg_conf
        execute :service, "postgresql", "restart"
      end
    end

    task :create_user do
      privileged_on primary(:db) do
        user = fetch(:fiftyfive_postgresql_user)

        unless test("sudo -u postgres psql -c '\\du' | grep -q #{user}")
          passwd = fetch(:fiftyfive_postgresql_password)
          execute %Q[sudo -u postgres psql -c "create user #{user} with password '#{passwd}';"]
        end
      end
    end

    task :create_database do
      privileged_on primary(:db) do
        user = fetch(:fiftyfive_postgresql_user)
        db = fetch(:fiftyfive_postgresql_database)

        unless test("sudo -u postgres psql -l | grep -w -q #{db}")
          execute "sudo -u postgres createdb -O #{user} #{db}"
        end
      end
    end

    task :database_yml do
      fetch(:fiftyfive_postgresql_password)
      on release_roles(:all) do
        template "postgresql.yml.erb",
                 "#{shared_path}/config/database.yml",
                 :mode => "600"
      end
    end

    task :pgpass do
      fetch(:fiftyfive_postgresql_password)
      on release_roles(:all) do
        template "pgpass.erb",
                 fetch(:fiftyfive_postgresql_pgpass_path),
                 :mode => "600"
      end
    end

    task :logrotate_backup do
      on roles(:backup) do
        backup_path = fetch(:fiftyfive_postgresql_backup_path)
        execute :mkdir, "-p", File.dirname(backup_path)
        execute :touch, backup_path
      end

      privileged_on roles(:backup) do |host, user|
        template\
          "postgresql-backup-logrotate.erb",
          "/etc/logrotate.d/postgresql-backup-#{application_basename}",
          :owner => "root:root",
          :mode => "644",
          :binding => binding
      end
    end
  end
end
