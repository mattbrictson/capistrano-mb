# capistrano-fiftyfive

**Additional recipes for use with Capistrano 3.x to automate installation of a
full-stack Rails environment!** No need to mess with Chef, Puppet, etc.
Several of these recipes are based on the
[Capistrano Recipes (#337)][cast337] and
[Zero-Downtime Deployment (#373)][cast373] episodes of RailsCasts.

We use these recipes at 55 Minutes to standardize our Rails deployments.
All recipes are tailored for:

* Ubuntu 12.04 LTS
* PostgreSQL
* Unicorn
* Nginx
* rbenv
* delayed_job
* [Postmark][] for mail delivery


## Installation

Please note that this project requires **Capistrano 3.x** which is complete
rewrite of the Capistrano 2.x you may be used to. The two versions are not
compatible.

### 1. Gemfile

Add these gems to the development group of your Rails application's Gemfile:

    group :development do
      gem 'capistrano-bundler'
      gem 'capistrano-rails'
      gem 'capistrano-fiftyfive', :github => '55minutes/capistrano-fiftyfive', :branch => "capistrano-3.0"
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
    require 'capistrano/fiftyfive'
    require 'capistrano/rails/assets'


### 4. Choose which recipes to auto-run

Most of the capistrano-fiftyfive recipes are designed to run automatically as
part of `cap [stage] deploy`. Several recipes also contribute to
`cap [stage] provision`, for installing and setting up various bits of the
Rails infrastructure, like nginx, unicorn, and postgres.

*This auto-run behavior is fully under your control.*  In your `deploy.rb`,
set `:fiftyfive_recipes` to an array of the desired recipes.
If you don't want a recipe to execute as part of `deploy`, simple omit it from
the list.

This list will suffice for most out-of-the-box Rails apps. The order of the
list is not important.

    set :fiftyfive_recipes, %w(
      aptitude
      logrotate
      migrate
      nginx
      postgresql
      rbenv
      secrets
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
entire setup of a bare Ubuntu 12.04 server, all the way to a fully configured
and running Rails app on top up Unicorn, Nginx, rbenv, and PostgreSQL.

Of course, if you want full control, feel free to fork this project and make
it your own.

### Deploying to a new server from scratch

These steps assume you have loaded the full set of capistrano-fiftyfive
recipes in your Capfile.

1. Provision an Ubuntu 12.04 VPS at your hosting provider of choice.
2. Install your public SSH key for the root user.
3. SSH into that VPS as root and run `aptitude update && aptitude safe-upgrade`
   to ensure your server has the latest packages.
4. Repeat steps 1 and 2 for all the servers in your cluster, if you are using
   a multi-server setup (e.g. separate web, app, and database servers).
5. Let capistrano-fiftyfive take it from here:

        cap provision
        cap deploy

### Running individual tasks

For a full description of the recipes you've installed, run:

    cap -T

All tasks from capistrano-fiftyfive will be prefixed with `fiftyfive:`. You
can run these tasks just like any other capistrano task, like so:

    cap staging fiftyfive:migrate


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[Postmark]:https://postmarkapp.com
[cast337]:http://railscasts.com/episodes/337-capistrano-recipes
[cast373]:http://railscasts.com/episodes/373-zero-downtime-deployment
[defaults.rake]:https://github.com/55minutes/rails-starter/blob/master/.rspec
[rails-starter]:https://github.com/55minutes/rails-starter/tree/master/config
