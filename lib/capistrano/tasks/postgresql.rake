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
    desc "Update postgresql.conf using pgtune"
    task :tune do
      privileged_on primary(:db), :in => :sequence do
        pgtune_dir = "/tmp/pgtune"
        pgtune_output = "/tmp/postgresql.conf.pgtune"
        pg_conf = "/etc/postgresql/9.1/main/postgresql.conf"

        execute :sudo, "rm", "-rf", pgtune_dir
        execute :sudo, "git",
                "clone",
                "-q",
                "https://github.com/gregs1104/pgtune.git",
                pgtune_dir

        execute "sudo #{pgtune_dir}/pgtune",
                "--input-config", pg_conf,
                "--output-config", pgtune_output,
                "--type", "Web",
                "--connections", fetch(:fiftyfive_postgresql_max_connections)

        # Log diff for informational purposes
        execute :sudo, "diff", pg_conf, pgtune_output, "|| true"

        execute :sudo, "cp", pgtune_output, pg_conf
        execute :sudo, "service", "postgresql", "restart"
      end
    end

    desc "Create user if it doesn't already exist"
    task :create_user do
      privileged_on primary(:db) do
        user = fetch(:fiftyfive_postgresql_user)

        unless test("sudo -u postgres psql -c '\\du' | grep -q #{user}")
          passwd = fetch(:fiftyfive_postgresql_password)
          md5 = Digest::MD5.hexdigest(passwd + user)
          execute "sudo -u postgres psql -c " +
                  %Q["CREATE USER #{user} PASSWORD 'md5#{md5}';"]
        end
      end
    end

    desc "Create database if it doesn't already exist"
    task :create_database do
      privileged_on primary(:db) do
        user = fetch(:fiftyfive_postgresql_user)
        db = fetch(:fiftyfive_postgresql_database)

        unless test("sudo -u postgres psql -l | grep -w -q #{db}")
          execute "sudo -u postgres createdb -O #{user} #{db}"
        end
      end
    end

    desc "Generate database.yml"
    task :database_yml do
      yaml = {
        fetch(:rails_env).to_s => {
          "adapter" => "postgresql",
          "encoding" => "unicode",
          "database" => fetch(:fiftyfive_postgresql_database).to_s,
          "pool" => fetch(:fiftyfive_postgresql_pool_size).to_i,
          "username" => fetch(:fiftyfive_postgresql_user).to_s,
          "password" => fetch(:fiftyfive_postgresql_password).to_s,
          "host" => fetch(:fiftyfive_postgresql_host).to_s
        }
      }
      fetch(:fiftyfive_postgresql_password)
      on release_roles(:all) do
        put YAML.dump(yaml),
            "#{shared_path}/config/database.yml",
            :mode => "600"
      end
    end

    desc "Generate pgpass file (needed by backup scripts)"
    task :pgpass do
      fetch(:fiftyfive_postgresql_password)
      on release_roles(:all) do
        template "pgpass.erb",
                 fetch(:fiftyfive_postgresql_pgpass_path),
                 :mode => "600"
      end
    end

    desc "Configure logrotate to back up the database daily"
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
          :binding => binding,
          :sudo => true
      end
    end

    desc "Dump the database to FILE"
    task :dump do
      on primary(:db) do
        with_pgpassfile do
          execute :pg_dump,
            "-Fc -Z9 -O",
            "-x", fetch(:fiftyfive_postgresql_dump_options),
            "-f", remote_dump_file,
            connection_flags,
            fetch(:fiftyfive_postgresql_database)
        end

        download!(remote_dump_file, local_dump_file)

        info(
          "Exported #{fetch(:fiftyfive_postgresql_database)} "\
          "to #{local_dump_file}."
          )
      end
    end

    desc "Restore database from FILE"
    task :restore do
      on primary(:db) do
        exit 1 unless agree(
          "\nErase existing #{fetch(:rails_env)} database "\
          "and restore from local file: #{local_dump_file}? "
          )

        upload!(local_dump_file, remote_dump_file)

        with_pgpassfile do
          execute :pg_restore,
            "-O -c",
            connection_flags,
            "-d", fetch(:fiftyfive_postgresql_database),
            remote_dump_file
        end
      end
    end

    def local_dump_file
      ENV.fetch("FILE", "#{fetch(:fiftyfive_postgresql_database)}.dmp")
    end

    def remote_dump_file
      "/tmp/#{fetch(:fiftyfive_postgresql_database)}.dmp"
    end

    def connection_flags
      [
        "-U", fetch(:fiftyfive_postgresql_user),
        "-h", fetch(:fiftyfive_postgresql_host)
      ].join(" ")
    end

    def with_pgpassfile(&block)
      with(:pgpassfile => fetch(:fiftyfive_postgresql_pgpass_path), &block)
    end
  end
end
