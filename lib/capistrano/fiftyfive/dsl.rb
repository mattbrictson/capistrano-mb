module Capistrano
  module Fiftyfive
    module DSL

      # Invoke the given task. If a task with that name is not defined,
      # silently skip it.
      #
      def invoke_if_defined(task)
        invoke(task) if Rake::Task.task_defined?(task)
      end

      # Used internally by capistrano-fiftyfive to register tasks such that
      # those tasks are executed conditionally based on the presence of the
      # recipe name in fetch(:fiftyfive_recipes).
      #
      #   fiftyfive_recipe :aptitude do
      #     during :provision, %w(task1 task2 ...)
      #   end
      #
      def fiftyfive_recipe(recipe_name, &block)
        Recipe.new(recipe_name).instance_exec(&block)
      end

      # Helper for calling fetch(:application) and making the value safe for
      # using in filenames, usernames, etc. Replaces non-word characters with
      # underscores.
      #
      def application_basename
        fetch(:application).to_s.gsub(/[^a-zA-Z0-9_]/, "_")
      end

      # Like capistrano's built-in ask(), but does not echo user input.
      # Suitable for passwords, etc. Requires the highline gem.
      #
      #   ask_secretly(:postgresql_password)
      #
      def ask_secretly(key, default=nil)
        require "highline"
        set key, proc{
          hint = default ? " [#{default}]" : ""
          answer = HighLine.new.ask("Enter #{key}#{hint}: ") do |q|
            q.echo = false
          end.to_s
        }
      end

      # Like capistrano's built-in on(), but connects to the server as root.
      # To use a user other than root, set :fiftyfive_privileged_user or
      # specify :privileged_user as a server property.
      #
      #   task :reboot do
      #     privileged_on roles(:all) do
      #       execute :shutdown, "-r", "now"
      #     end
      #   end
      #
      def privileged_on(*args, &block)
        on(*args) do |host|
          if host.nil?
            instance_exec(nil, nil, &block)
          else
            original_user = host.user

            begin
              host.user = host.properties.privileged_user ||
                          fetch(:fiftyfive_privileged_user)
              instance_exec(host, original_user, &block)
            ensure
              host.user = original_user
            end
          end
        end
      end

      # Uploads the given string or file-like object to the current host
      # context. Intended to be used within an on() or privileged_on() block.
      # Accepts :owner and :mode options that affect the permissions of the
      # remote file.
      #
      def put(string_or_io, remote_path, opts={})
        owner = opts[:owner]
        mode = opts[:mode]

        source = if string_or_io.respond_to?(:read)
          string_or_io
        else
          StringIO.new(string_or_io.to_s)
        end

        execute :mkdir, "-p", File.dirname(remote_path)

        upload!(source, remote_path)

        execute(:chown, owner, remote_path) if owner
        execute(:chmod, mode, remote_path) if mode
      end


      # Read the specified file from the local system, interpret it as ERb,
      # and upload it to the current host context. Intended to be used with an
      # on() or privileged_on() block. Accepts :owner, :mode, and :binding
      # options.
      #
      # Templates with relative paths are first searched for in
      # lib/capistrano/fiftyfive/templates in the current project. This gives
      # applications a chance to override. If an override is not found, the
      # default template within the capistrano-fiftyfive gem is used.
      #
      #   task :create_database_yml do
      #     on roles(:app, :db) do
      #       within(shared_path) do
      #         template fetch(:database_yml_template_path),
      #                  "config/database.yml",
      #                  :mode => "600"
      #       end
      #     end
      #   end
      #
      def template(local_path, remote_path, opts={})
        binding = opts[:binding] || binding

        unless local_path.start_with?("/")
          override_path = \
            File.join("lib/capistrano/fiftyfive/templates", local_path)

          local_path = if File.exist?(override_path)
            override_path
          else
            File.expand_path(File.join("../templates", local_path), __FILE__)
          end
        end

        erb = File.read(local_path)
        rendered_template = ERB.new(erb).result(binding)

        put(rendered_template, remote_path, opts)
      end
    end
  end
end
