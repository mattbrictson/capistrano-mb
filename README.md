# capistrano-fiftyfive

[![Join the chat at https://gitter.im/mattbrictson/capistrano-fiftyfive](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/mattbrictson/capistrano-fiftyfive?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Gem Version](https://badge.fury.io/rb/capistrano-fiftyfive.svg)](http://badge.fury.io/rb/capistrano-fiftyfive)

Capistrano is great for deploying Rails applications, but what about all the prerequisites, like Nginx and PostgreSQL? Do you have a firewall configured on your VPS? Have you installed the latest OS security updates? Is HTTPS working right?

The capistrano-fiftyfive gem adds a `cap <stage> provision` task to Capistrano that takes care of all that. Out of the box, `provision` will:

* Install the latest `postgresql`, `node.js`, and `nginx` apt packages
* Install all libraries needed to build Ruby
* Lock down your VPS using `ufw` (a simple front-end to iptables)
* Set up `logrotated` for your Rails logs
* Schedule an automatic daily backup of your Rails database
* Generate a self-signed SSL certificate if you need one
* Set up ngnix with the latest SSL practices and integrate it with Unicorn for your Rails app
* Create the `deployer` user and install an SSH public key
* Install `rbenv` and use `ruby-build` to compile the version of Ruby required by your app (by inspecting your `.ruby-version` file)
* And more!

The gem is named "capistrano-fiftyfive" for historical reasons: it was initially built by [55 Minutes](http://55minutes.com) to automate deployments of its Rails projects. You'll notice that capistrano-fiftyfive is opinionated and strictly uses the following stack:

* Ubuntu 12.04 LTS or 14.04 LTS
* PostgreSQL
* Unicorn
* Nginx
* rbenv
* dotenv

In addition, capistrano-fiftyfive changes many of Capistrano's defaults, including the deployment location, Bundler behavior, and SSH keep-alive settings. (See [defaults.rake][] for details.)

Not quite to your liking? Consider forking the project to meet your needs.


## Installation

Please note that this project requires **Capistrano 3.x**, which is a complete
rewrite of Capistrano 2.x. The two major versions are not compatible.

### 1. Gemfile

Add these gems to the development group of your Rails application's Gemfile:

    group :development do
      gem 'capistrano-bundler', :require => false
      gem 'capistrano-rails', :require => false
      gem 'capistrano', '~> 3.4.0', :require => false
      gem 'capistrano-fiftyfive' :require => false
    end

And then execute:

    $ bundle


### 2. cap install

If your project doesn't yet have a `Capfile`, run `cap install` with the list
of desired stages (environments):

    cap install STAGES=staging,production


### 3. Capfile

Add these lines to the **bottom** of your app's `Capfile`
(order is important!):

    require 'capistrano/bundler'
    require 'capistrano/rails'
    require 'capistrano/fiftyfive'


### 4. Choose which recipes to auto-run

Most of the capistrano-fiftyfive recipes are designed to run automatically as part of `cap <stage> provision`, for installing and setting up various bits of the Rails infrastructure, like nginx, unicorn, and postgres. Some recipes also contribute to the `cap <stage> deploy` process.

*This auto-run behavior is fully under your control.*  In your `deploy.rb`,
set `:fiftyfive_recipes` to an array of the desired recipes.
If you don't want a recipe to execute as part of `deploy`/`provision`, simply omit it from
the list.

The following list will suffice for most out-of-the-box Rails apps. The order of the list is not important.

    set :fiftyfive_recipes, %w(
      aptitude
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

Even if you don't include a recipe in the auto-run list, you can still invoke
the tasks of those recipes manually at your discretion.


### 5. Configuration

Many of the recipes have default settings that can be overridden. Use your
`deploy.rb` file to specify these overrides. Or, you can override per stage.
Here is an example override:

    set :fiftyfive_unicorn_workers, 8

For the full list of settings and their default values, refer to
[defaults.rake][].


### A working example

Check out our [rails-starter][] project for a sample Capfile and deploy.rb.

## Usage

The power of the capistrano-fiftyfive recipes is that they take care of the
entire setup of a bare Ubuntu 12.04 or 14.04 server, all the way to a fully configured
and running Rails app on top up Unicorn, Nginx, rbenv, and PostgreSQL.

### Deploying to a new server from scratch

These steps assume you have loaded the full set of capistrano-fiftyfive
recipes in your Capfile.

1. Provision an Ubuntu 12.04 or 14.04 VPS at your hosting provider of choice.
2. Install your public SSH key for the root user. Some providers (e.g. DigitalOcean) can do this for you automatically when you provision a new VPS.
3. Repeat steps 1-2 for all the servers in your cluster, if you are using
   a multi-server setup (e.g. separate web, app, and database servers).
4. Let capistrano-fiftyfive take it from here:

        cap staging provision       # for 12.04 LTS
        cap staging provision:14_04 # for 14.04 LTS
        cap staging deploy

### Running individual tasks

For a full description of all available tasks, run:

    cap -T

All tasks from capistrano-fiftyfive will be prefixed with `fiftyfive:`. You
can run these tasks just like any other capistrano task, like so:

    cap staging fiftyfive:seed


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[Postmark]:https://postmarkapp.com
[cast337]:http://railscasts.com/episodes/337-capistrano-recipes
[cast373]:http://railscasts.com/episodes/373-zero-downtime-deployment
[defaults.rake]:lib/capistrano/tasks/defaults.rake
[rails-starter]:https://github.com/mattbrictson/rails-starter/tree/master/config
