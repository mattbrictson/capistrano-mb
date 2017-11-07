require "digest"
require "monitor"
require "capistrano/mb/version"
require "capistrano/mb/compatibility"
require "capistrano/mb/dsl"
require "capistrano/mb/recipe"
include Capistrano::MB::DSL

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
load File.expand_path("../tasks/crontab.rake", __FILE__)
load File.expand_path("../tasks/logrotate.rake", __FILE__)
load File.expand_path("../tasks/rbenv.rake", __FILE__)
load File.expand_path("../tasks/maintenance.rake", __FILE__)
load File.expand_path("../tasks/migrate.rake", __FILE__)
load File.expand_path("../tasks/seed.rake", __FILE__)
load File.expand_path("../tasks/version.rake", __FILE__)
load File.expand_path("../tasks/rake.rake", __FILE__)
load File.expand_path("../tasks/sidekiq.rake", __FILE__)
load File.expand_path("../tasks/bundler.rake", __FILE__)
