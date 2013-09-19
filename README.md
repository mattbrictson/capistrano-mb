# capistrano-fiftyfive

**Additional recipes for use with capistrano to automate installation of a
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

### 1. Gemfile

Add the capistrano-fiftyfive gem to the development group of your Rails
application's Gemfile:

    group :development do
      gem 'capistrano-fiftyfive', :github => '55minutes/capistrano-fiftyfive', :branch => :master
    end

If you plan on using the `dotenv` recipe (recommended), make sure you also
include the dotenv-rails gem:

    gem 'dotenv-rails'

And then execute:

    $ bundle


### 2. Load the recipes

Add this to your app's `config/deploy.rb`:

    require "capistrano/fiftyfive"
    Capistrano::Fiftyfive.load(:autorun => true)
    set :project_root, File.expand_path("../..", __FILE__)

**This will load all the capistrano-fiftyfive recipes, and run their tasks
automatically during appropriate times of the deploy lifecycle.** If you
want to customize this behavior, see step 3 below.

Many of the recipes have default settings that can be overridden. Use your
deploy.rb file to specify these overrides. If you use multistage, you can do
environment-specific overrides. Here's an example:

    set :unicorn_workers, 8

See the Reference section below for the full list of settings and their
default values.


### 3. (Advanced) Customize which recipes are loaded and executed

Certain recipes can be excluded, using the `:exclude` option:

    Capistrano::Fiftyfive.load(:exclude => [:cron, :delayed_job], :autorun => true)

If you know exactly the recipes you want, use `:only`:

    Capistrano::Fiftyfive.load(:only => [:nginx, :unicorn], :autorun => true)

If you want full control over how tasks are incorporated into the deploy
process, set `:autorun => false`. Then declare your own rules using the
standard capistrano hooks. For example:

    Capistrano::Fiftyfive.load(:only => :postgresql, :autorun => false)
    after "deploy:finalize_update", "fiftyfive:postgresql:symlink"


### A working example

Check out our [rails-starter][] project for a sample deploy.rb with multistage
integration.


## Usage

The power of the capistrano-fiftyfive recipes is that they take care of the
entire setup of a bare Ubuntu 12.04 server, all the way to a fully configured
and running Rails app on top up Unicorn, Nginx, rbenv, and PostgreSQL.

Of course, if you want full control, you can also run tasks individually.

### Deploying to a new server from scratch

These steps assume you have loaded the full set of capistrano-fiftyfive
recipes in your deploy.rb, including `:autorun => true`.

1. Provision an Ubuntu 12.04 VPS at your hosting provider of choice.
2. SSH into that VPS as root and run `aptitude update && aptitude safe-upgrade`
3. Create the admin group: `groupadd admin`
4. Create a deployer user in that group: `adduser deployer --ingroup admin`
6. If you have an SSL key and certificate prepared, install them in `/etc/ssl`. Otherwise, you can run `cap fiftyfive:ssl:generate_self_signed_crt` to quickly create a temporary self-signed one.
7. Now, from your Rails project on your local machine, fire off these commands. These will install various packages, compile Ruby, set up the database, and deploy your app.

        cap deploy:install
        cap deploy:setup
        cap deploy:cold

### Running individual tasks

For a full description of the recipes you've installed, run:

    cap -T

All tasks from capistrano-fiftyfive will be prefixed with `fiftyfive:`. You
can run these tasks just like any other capistrano task, like so:

    cap fiftyfive:postgresql:setup_pgpass


## Reference

TODO


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[Postmark]:https://postmarkapp.com
[cast337]:http://railscasts.com/episodes/337-capistrano-recipes
[cast373]:http://railscasts.com/episodes/373-zero-downtime-deployment
[hooks]:https://github.com/55minutes/capistrano-fiftyfive/blob/master/lib/capistrano/fiftyfive/autorun.rb
[rails-starter]:https://github.com/55minutes/rails-starter/tree/master/config
