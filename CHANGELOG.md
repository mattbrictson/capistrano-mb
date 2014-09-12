# capistrano-fiftyfive Changelog

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
