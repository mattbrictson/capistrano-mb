# capistrano-fiftyfive Changelog

## `0.15.2`

* The capistrano-fiftyfive GitHub repository has changed: it is now <https://github.com/mattbrictson/capistrano-fiftyfive>.

## `0.15.1`

* Remove `-j4` bundler flag

## `0.15.0`

* Dump useful troubleshooting information when a deploy fails.
* Nginx/unicorn: fix syntax errors introduced by changes in 0.14.0, ensuring that gzip and far-future expires headers are sent as expected.

## `0.14.0`

* The `highline` gem is now a dependency ([#3](https://github.com/mattbrictson/capistrano-fiftyfive/pull/3) from [@ahmozkya](https://github.com/ahmozkya)).
* Dotenv: only mask input when prompting for keys containing the words "key", "secret", "token", or "password". Input for other keys is echoed for easier data entry.
* Dotenv: update `.env` files in sequence rather than in parallel, to avoid parallel command output clobbering the input prompt.
* Nginx/unicorn: tweak reverse-proxy cache settings to prevent cache stampede.
* Nginx/unicorn: apply far-future expires cache headers only for assets that have fingerprints.

## `0.13.0`

The provisioning tasks now work for a non-root user that has password-less sudo privileges. Assuming a user named `matt` that can sudo without being prompted for a password ([instructions here](http://askubuntu.com/questions/192050/how-to-run-sudo-command-with-no-password)), simply modify `deploy.rb` with:

```ruby
set :fiftyfive_privileged_user, "matt"
```

Now all provisioning tasks that would normally run as root will instead run as `matt` using `sudo`.

## `0.12.0`

* capistrano-fiftyfive's abbreviated format now honors the new `SSHKIT_COLOR` environment variable. Set `SSHKIT_COLOR=1` to force ANSI color even on non-ttys (e.g. Jenkins).
* The generated nginx config now enables reverse proxy caching by default.
* INFO messages printed by sshkit are now printed to console under the appropriate rake task heading.

## `0.11.1`

Fixes errors caused by PostgreSQL password containing shell-unsafe characters. Passwords are now safely hashed with MD5 before being used in the `CREATE USER` command.

## `0.11.0`

* INFO log messages are now included in abbreviated output (e.g. upload/download progress).
* Add `agree()` method to the DSL, which delegates to `HighLine.new.agree`.
* Add `fiftyfive:postgresql:dump`/`restore` tasks.

## `0.10.0`

Add support for Ubuntu 14.04 LTS. To provision a 14.04 server, use the new `provision:14_04` task.

## `0.9.1`

Flush console output after each line is printed. This allows deployment progress to be monitored in e.g. Jenkins.

## `0.9.0`

Initial Rubygems release!
