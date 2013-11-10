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
      on roles(:all) do
        template "postgresql.yml.erb",
                 "#{shared_path}/config/database.yml",
                 :mode => "600"
      end
    end

    task :pgpass do
      fetch(:fiftyfive_postgresql_password)
      on roles(:all) do
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
