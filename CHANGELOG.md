## [Unreleased][]

* Your contribution here!

## [0.33.0][] (2017-12-29)

* Remove the deprecated `fiftyfive` compatibility layer
* Drop compatibility with older Ubuntu releases; now only Ubuntu 16.04 is supported via a single `provision` task
* Remove dependencies on `ppa:pitti` and `ppa:chris-lea` for postgres and node.js, respectively; use the official Ubuntu releases instead
* Replace init_d scripts with systemd configs
* Completely remove delayed_job support

## [0.32.0][] (2017-05-26)

* Add [immutable cache-control header](https://code.facebook.com/posts/557147474482256) to further boost performance of static assets
* Prefer IPv4 when fetching apt repo keys

## [0.31.0][] (2016-10-14)

* Ensure `software-properties-common` package is installed during `provision:14_04` so that `apt-add-repository` works.
* Don't echo dotenv values for keys with `pepper` in the name.
* Add `ntp` to the list of packages installed on all server roles.
* Fix "Capistrano tasks may only be invoked once" warning when using `deploy:migrate_and_restart` with Sidekiq.

## [0.30.0][] (2016-08-30)

* Change the hooks such that `mb:crontab` is run at the end of every deployment,
  rather than once during provisioning. This means that the crontab will now be
  regenerated and installed every time you `cap deploy`.
* Fix a `NoMethodError` when showing certain compatibility warnings [#14](https://github.com/mattbrictson/capistrano-mb/issues/14)

## [0.29.0][] (2016-07-19)

* Add `public/.well-known` to `:linked_dirs` to support Let's Encrypt renewals.
* Fix recipe definition code so that Capistrano's `invoke` is not used
  redundantly. This is not a change in behavior, but it does fix a warning that
  is printed starting in Capistrano 3.6.0.

## [0.28.0][] (2016-05-13)

* Add `--quiet` to the default `bundle install` flags
* Enable SSH compression by default, now that zlib warning has been fixed in
  SSHKit 1.10.0

## [0.27.0][] (2016-02-19)

* Symlink `.bundle` so that every release shares the same `.bundle/config`. This allows `bundle:check` to work, speeding up deployments when the Gemfile hasn't changed.
* Work around a regression in capistrano-bundler so that the Bundler path stays the same. See [capistrano-bundler #79](https://github.com/capistrano/bundler/pull/79).

## [0.26.0][] (2016-01-08)

* Remove `mb:postgresql:tune` task. The [pgtune](https://github.com/gregs1104/pgtune) tool no longer works with the latest versions of PostgresSQL.
* Overhaul the `mb:rbenv:*` tasks.
  * Use the official rbenv-installer script
  * Install necessary dev packages via `mb:aptitude:install` rather than relying on an external (and outdated) script
  * Remove several unused rbenv plugins, keeping only: `ruby-build`, `rbenv-vars`, `rbenv-update`
  * Install plugins using our own code, rather than using external script
  * No longer install the `psych` gem

## [0.25.0][] (2015-10-09)

* Add `X-Accel-Mapping` and appropriate NGINX configuration so that `send_file` used in a Rails controller is now accelerated using `X-Accel-Redirect`. For security this only works if the file being sent resides in the Rails app directory (e.g. `<rails_root>/tmp` or `<rails_root>/public`). This means `send_file` files will be served by NGINX natively, rather than through Rack.

## [0.24.0][] (2015-09-11)

* Improve README with step-by-step installation instructions.
* Expand the list of cipher suites used in the nginx SSL configuration. ([#7](https://github.com/mattbrictson/capistrano-mb/pull/7))

## [0.23.1][] (2015-08-08)

* Ensure gzip is enable for all assets, not just fingerprinted ones.

## [0.23.0][] (2015-07-10)

This release introduces a `bundler` recipe that automatically installs or upgrades bundler using `gem install bundler` during `cap deploy`. To disable this behavior:

```ruby
set :mb_bundler_gem_install_command, nil
```

Other changes:

* No longer assume that the `colorize` gem is available (it may be removed in an upcoming version of SSHKit/capistrano).

## [0.22.2][] (2015-06-22)

* For backwards compatibility with capistrano-fiftyfive, also search `lib/capistrano/fiftyfive/templates` for template files (the preferred location is `lib/capistrano/mb/templates`).

## [0.22.1][] (2015-06-22)

* Remove "capistrano-fiftyfive has been renamed to capistrano-mb" post-install message.

## [0.22.0][] (2015-06-22)

**THIS GEM HAS A NEW NAME! It is now `capistrano-mb`.**

* All settings now use the `mb_` prefix. E.g. if you are using `set(:fiftyfive_recipies, ...)`, change it to `set(:mb_recipes, ...)`.
* All tasks now use the `mb` namespace. E.g. `cap fiftyfive:crontab` is now `cap mb:crontab`.
* For backwards compatibility, you can still use the `fiftyfive` versions, but a deprecation warning will be printed. This compatibility will be removed in capistrano-mb 1.0.

## [0.21.0][] (2015-06-22)

* Add a post-install message explaining the rename of `capistrano-fiftyfive` to `capistrano-mb`.

## [0.20.1][] (2015-05-29)

* An internal change in Capistrano 3.4.0 caused `fiftyfive:aptitude:install` to fail to install packages. This is now fixed.

## [0.20.0][] (2015-05-29)

* Increase SSL/TLS security of the generated nginx configuration by following the suggestions of [weakdh.org](https://weakdh.org/sysadmin.html).

## [0.19.0][] (2015-04-10)

* Add `--retry=3` to bundle install options. This will help prevent deployment failures in case that a gem initially fails to download during the `bundle install` step.
* Ensure that `--dry-run` works without crashing. This involved working around Capistrano's `download!` behavior (it returns a String normally, but an entirely different object during a dry run).

## [0.18.0][]

* **The abbreviated log formatter has been removed and is now available in a new gem: `airbrussh`.** With this change, capistrano-fiftyfive no longer automatically changes the logging format of capistrano. To opt into the prettier, more concise format, add the airbrussh gem to your project as explained in the [airbrussh README](https://github.com/mattbrictson/airbrussh#readme).
* The version initializer that capistrano-fiftyfive adds during deployment sets a new value: `Rails.application.config.version_time`. You can use this value within your app for the date and time of the last commit that produced the version that is currently deployed.


## [0.17.2][]

* Default self-signed SSL certificate is now more generic (for real this time).

## [0.17.1][]

* Cosmetic changes to the gemspec.

## [0.17.0][]

* Write a banner message into `capistrano.log` at the start of each cap run, to aid in troubleshooting.
* Default self-signed SSL certificate is now more generic.

## [0.16.0][]

* capistrano-fiftyfive now requires capistrano >= 3.3.5 and sshkit => 1.6.1
* `ask_secretly` has been removed in favor of Capistrano's built-in `ask ..., :echo => false`
* `agree` no longer takes an optional second argument
* highline dependency removed
* Install libffi-dev so that Ruby 2.2.0 can be compiled

## [0.15.2][]

* The capistrano-fiftyfive GitHub repository has changed: it is now <https://github.com/mattbrictson/capistrano-fiftyfive>.

## [0.15.1][]

* Remove `-j4` bundler flag

## [0.15.0][]

* Dump useful troubleshooting information when a deploy fails.
* Nginx/unicorn: fix syntax errors introduced by changes in 0.14.0, ensuring that gzip and far-future expires headers are sent as expected.

## [0.14.0][]

* The `highline` gem is now a dependency ([#3](https://github.com/mattbrictson/capistrano-fiftyfive/pull/3) from [@ahmozkya](https://github.com/ahmozkya)).
* Dotenv: only mask input when prompting for keys containing the words "key", "secret", "token", or "password". Input for other keys is echoed for easier data entry.
* Dotenv: update `.env` files in sequence rather than in parallel, to avoid parallel command output clobbering the input prompt.
* Nginx/unicorn: tweak reverse-proxy cache settings to prevent cache stampede.
* Nginx/unicorn: apply far-future expires cache headers only for assets that have fingerprints.

## [0.13.0][]

The provisioning tasks now work for a non-root user that has password-less sudo privileges. Assuming a user named `matt` that can sudo without being prompted for a password ([instructions here](http://askubuntu.com/questions/192050/how-to-run-sudo-command-with-no-password)), simply modify `deploy.rb` with:

```ruby
set :fiftyfive_privileged_user, "matt"
```

Now all provisioning tasks that would normally run as root will instead run as `matt` using `sudo`.

## [0.12.0][]

* capistrano-fiftyfive's abbreviated format now honors the new `SSHKIT_COLOR` environment variable. Set `SSHKIT_COLOR=1` to force ANSI color even on non-ttys (e.g. Jenkins).
* The generated nginx config now enables reverse proxy caching by default.
* INFO messages printed by sshkit are now printed to console under the appropriate rake task heading.

## [0.11.1][]

Fixes errors caused by PostgreSQL password containing shell-unsafe characters. Passwords are now safely hashed with MD5 before being used in the `CREATE USER` command.

## [0.11.0][]

* INFO log messages are now included in abbreviated output (e.g. upload/download progress).
* Add `agree()` method to the DSL, which delegates to `HighLine.new.agree`.
* Add `fiftyfive:postgresql:dump`/`restore` tasks.

## [0.10.0][]

Add support for Ubuntu 14.04 LTS. To provision a 14.04 server, use the new `provision:14_04` task.

## [0.9.1][]

Flush console output after each line is printed. This allows deployment progress to be monitored in e.g. Jenkins.

## 0.9.0

Initial Rubygems release!

[Unreleased]: https://github.com/mattbrictson/capistrano-mb/compare/v0.33.0...HEAD
[0.33.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.32.0...v0.33.0
[0.32.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.31.0...v0.32.0
[0.31.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.30.0...v0.31.0
[0.30.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.29.0...v0.30.0
[0.29.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.28.0...v0.29.0
[0.28.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.27.0...v0.28.0
[0.27.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.26.0...v0.27.0
[0.26.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.25.0...v0.26.0
[0.25.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.24.0...v0.25.0
[0.24.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.23.1...v0.24.0
[0.23.1]: https://github.com/mattbrictson/capistrano-mb/compare/v0.23.0...v0.23.1
[0.23.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.22.2...v0.23.0
[0.22.2]: https://github.com/mattbrictson/capistrano-mb/compare/v0.22.1...v0.22.2
[0.22.1]: https://github.com/mattbrictson/capistrano-mb/compare/v0.22.0...v0.22.1
[0.22.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.21.0...v0.22.0
[0.21.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.20.1...v0.21.0
[0.20.1]: https://github.com/mattbrictson/capistrano-mb/compare/v0.20.0...v0.20.1
[0.20.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.19.0...v0.20.0
[0.19.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.18.0...v0.19.0
[0.18.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.17.2...v0.18.0
[0.17.2]: https://github.com/mattbrictson/capistrano-mb/compare/v0.17.1...v0.17.2
[0.17.1]: https://github.com/mattbrictson/capistrano-mb/compare/v0.17.0...v0.17.1
[0.17.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.16.0...v0.17.0
[0.16.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.15.2...v0.16.0
[0.15.2]: https://github.com/mattbrictson/capistrano-mb/compare/v0.15.1...v0.15.2
[0.15.1]: https://github.com/mattbrictson/capistrano-mb/compare/v0.15.0...v0.15.1
[0.15.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.14.0...v0.15.0
[0.14.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.13.0...v0.14.0
[0.13.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.12.0...v0.13.0
[0.12.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.11.1...v0.12.0
[0.11.1]: https://github.com/mattbrictson/capistrano-mb/compare/v0.11.0...v0.11.1
[0.11.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/mattbrictson/capistrano-mb/compare/v0.9.1...v0.10.0
[0.9.1]: https://github.com/mattbrictson/capistrano-mb/compare/v0.9.0...v0.9.1
