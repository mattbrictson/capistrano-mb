if defined?(Capistrano::Configuration)
  Capistrano::Configuration.instance(:must_exist).load do
    namespace :fiftyfive do

      def set_default(name, *args, &block)
        set(name, *args, &block) unless exists?(name)
      end

      def template(from, to, opts={})
        owner = opts.delete(:owner)

        unless from.start_with?("/")
          from = File.expand_path("../templates/#{from}", __FILE__)
        end

        erb = File.read(from)
        rendered_template = ERB.new(erb).result(binding)

        if opts.delete(:sudo)
          put(rendered_template, "/tmp/rendered_template", opts)
          run("#{sudo} mv /tmp/rendered_template #{to}", opts)
        else
          put(rendered_template, to, opts)
        end

        if owner
          run("#{sudo} chown #{owner} #{to}")
        end
      end

      def aptitude_update(opts={})
        if opts[:force] || ! fetch(:fiftyfive_utils_aptitude_update, false)
          run "#{sudo} aptitude -q -q -y update"
          set(:fiftyfive_utils_aptitude_update, true)
        end
      end

      def install_packages(*packages)
        aptitude_update
        run "#{sudo} aptitude -y install #{packages.join(' ')}"
      end

      def install_package(package)
        install_packages(package)
      end

      def add_package_repository(repo)
        install_package("python-software-properties")
        run "#{sudo} add-apt-repository -y #{repo}"
      end

      def write_rbenv_var(name, value)
        run "mkdir -p ~/.rbenv"
        run "touch ~/.rbenv/vars"
        run "chmod 0600 ~/.rbenv/vars"

        run "sed --in-place '/^#{name}=/d' ~/.rbenv/vars"

        put "#{name}=#{value}\n", "/tmp/rbenv_var"
        run "cat /tmp/rbenv_var >> ~/.rbenv/vars"
        run "rm /tmp/rbenv_var"
      end
    end
  end
end
