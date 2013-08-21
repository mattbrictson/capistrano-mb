require "capistrano/fiftyfive/utils"
require "capistrano/fiftyfive/version"


module Capistrano
  module Fiftyfive
    def self.load(*)
      raise "Capistrano::Fiftyfive.load can only be called from a Capistrano environment"
    end
  end
end


if defined?(Capistrano::Configuration)

  Capistrano::Configuration.instance(:must_exist).load do
    # Capistrano doesn't have a deploy:install task by default, so create one.
    unless find_task("deploy:install")
      namespace :deploy do
        desc "Install required packages"
        task :install do
        end
      end
    end
  end

  module Capistrano
    module Fiftyfive
      @config = Capistrano::Configuration.instance(:must_exist)

      def self.load(opts={})
        hooks = self.hooks
        recipes = recipes_matching(opts)

        recipes.each do |recipe|
          @config.load { require recipe.path }

          recipe_hooks = hooks[recipe.name]
          @config.load(&recipe_hooks) unless recipe_hooks.nil?
        end
      end

      def self.register_hooks(recipe_name, &block)
        hooks[recipe_name.to_s] = block
      end

      private

      Recipe = Struct.new(:path) do
        def name
          File.basename(path, ".rb")
        end
      end

      def self.hooks
        @hooks ||= Hash.new
      end

      def self.recipes_matching(opts)
        recipes_dir = File.join(File.dirname(__FILE__), "fiftyfive/recipes")
        recipe_files = Dir.glob("#{recipes_dir}/*.rb").sort

        only_names = recipe_names(opts[:only])
        except_names = recipe_names(opts[:except])

        recipes = recipe_files.map { |r| Recipe.new(r) }

        if (bad_names = (only_names + except_names) - recipes.map(&:name)).any?
          raise "Unknown recipe(s): #{bad_names.join(', ')}"
        end

        recipes.reject! { |r| except_names.include?(r.name) }
        recipes.select! { |r| only_names.include?(r.name) } if only_names.any?

        recipes
      end

      def self.recipe_names(name_or_array)
        array = if name_or_array.nil?
          []
        elsif name_or_array.respond_to?(:to_a)
          name_or_array.to_a
        else
          [name_or_array]
        end

        array.map(&:to_s)
      end
    end
  end

end
