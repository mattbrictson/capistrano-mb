module Capistrano
  module MB
    class Recipe
      attr_reader :name

      def initialize(name)
        @name = name.to_s
      end

      def enabled?
        fetch(:mb_recipes, []).map(&:to_s).include?(name)
      end

      def prior_to(task_to_extend, *recipe_tasks)
        inject_tasks(:before, task_to_extend, *recipe_tasks)
      end

      def during(task_to_extend, *recipe_tasks)
        inject_tasks(:after, task_to_extend, *recipe_tasks)
      end

      private

      def inject_tasks(method, task_to_extend, *recipe_tasks)
        create_task_unless_exists(task_to_extend)

        recipe_tasks.flatten.each do |task|
          qualified_task = apply_namespace(task)
          send(method, task_to_extend, "#{qualified_task}:if_enabled") do
            invoke qualified_task if enabled?
          end
        end
      end

      def apply_namespace(task_name)
        return task_name if task_name.include?(":")

        "mb:#{name}:#{task_name}"
      end

      def create_task_unless_exists(task_name)
        unless Rake::Task.task_defined?(task_name)
          Rake::Task.define_task(task_name)
        end
      end
    end
  end
end
