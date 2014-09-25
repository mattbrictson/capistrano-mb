require "digest"
require "highline"
require "monitor"
require "capistrano/fiftyfive/version"
require "capistrano/fiftyfive/compatibility"
require "capistrano/fiftyfive/dsl"
require "capistrano/fiftyfive/recipe"
require "capistrano/fiftyfive/console"
require "sshkit/formatter/abbreviated"
include Capistrano::Fiftyfive::DSL

load File.expand_path("../tasks/provision.rake", __FILE__)
load File.expand_path("../tasks/defaults.rake", __FILE__)
load File.expand_path("../tasks/user.rake", __FILE__)
load File.expand_path("../tasks/aptitude.rake", __FILE__)
load File.expand_path("../tasks/ufw.rake", __FILE__)
load File.expand_path("../tasks/ssl.rake", __FILE__)
load File.expand_path("../tasks/dotenv.rake", __FILE__)
load File.expand_path("../tasks/postgresql.rake", __FILE__)
load File.expand_path("../tasks/nginx.rake", __FILE__)
load File.expand_path("../tasks/unicorn.rake", __FILE__)
load File.expand_path("../tasks/delayed_job.rake", __FILE__)
load File.expand_path("../tasks/crontab.rake", __FILE__)
load File.expand_path("../tasks/logrotate.rake", __FILE__)
load File.expand_path("../tasks/rbenv.rake", __FILE__)
load File.expand_path("../tasks/maintenance.rake", __FILE__)
load File.expand_path("../tasks/migrate.rake", __FILE__)
load File.expand_path("../tasks/seed.rake", __FILE__)
load File.expand_path("../tasks/version.rake", __FILE__)
load File.expand_path("../tasks/rake.rake", __FILE__)
load File.expand_path("../tasks/sidekiq.rake", __FILE__)
load File.expand_path("../tasks/deploy.rake", __FILE__)
