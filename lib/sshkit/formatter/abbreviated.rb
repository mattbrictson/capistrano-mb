require 'colorize'
require 'io/console'

module SSHKit
  module Formatter
    class Abbreviated < SSHKit::Formatter::Abstract

      # TODO: use SSHKit::Color in SSHKit 1.5+ when released?
      class Color
        attr_reader :tty

        def initialize(output)
          @tty = output.tty?
        end

        String::COLORS.map(&:first).each do |style|
          define_method(style) do |string|
            return string unless tty
            string.colorize(style)
          end
        end
      end

      class << self
        attr_accessor :current_task

        def monkey_patch_rake_task!
          return if @rake_patched

          eval(<<-EVAL)
            class ::Rake::Task
              alias :_original_execute_cap55 :execute
              def execute(args=nil)
                SSHKit::Formatter::Abbreviated.current_task = name
                _original_execute_cap55(args)
              end
            end
          EVAL

          @rake_patched = true
        end
      end

      def initialize(io)
        super

        self.class.monkey_patch_rake_task!

        @log_file = fetch(:fiftyfive_log_file) || "capistrano.log"
        @log_file_formatter = SSHKit::Formatter::Pretty.new(
          ::Logger.new("log/capistrano.log", 1, 20971520)
        )

        original_output << "Using abbreviated format. " +
                           "Full cap output is being written to " +
                           c.blue(@log_file) + ".\n"
      end

      def write(obj)
        @log_file_formatter << obj

        case obj
        when SSHKit::Command    then write_command(obj)
        when SSHKit::LogMessage then write_log_message(obj)
        else
          original_output << "Output formatter doesn't know how to handle #{obj.class}\n"
        end
      end
      alias :<< :write

      private

      def write_command(command)
        return unless command.verbosity > SSHKit::Logger::DEBUG

        write_clock_and_current_task_once
        write_command_once(command)

        if command.finished?
          write_command_finished(command)
        end
      end

      def write_clock_and_current_task_once
        task = self.class.current_task
        return if @last_written_task == task
        @last_written_task = task

        original_output << clock + c.blue(task) + "\n"
      end

      def write_command_once(cmd, prefix="      ")
        cmd_str = prefix + cmd.to_s.sub(%r(^/usr/bin/env ), "")
        return if @last_commmand_s == cmd_str
        @last_commmand_s = cmd_str

        cmd_str = truncate_to_console(cmd_str)
        original_output << c.yellow(cmd_str) + "\n"
      end

      def write_command_finished(command, prefix="      ")
        user = command.user { command.host.user }
        host = command.host.to_s
        user_at_host = [user, host].join("@")
        elapsed = c.light_black(sprintf(" %5.3fs", command.runtime))

        status = if command.failure?
          c.red("✘ #{user_at_host} (see #{@log_file} for details)")
        else
          c.green("✔ #{user_at_host}")
        end

        original_output << prefix + status + elapsed + "\n"
      end

      def write_log_message(log_message)
        return unless log_message.verbosity > SSHKit::Logger::INFO
        original_output << log_message + "\n"
      end

      def truncate_to_console(str)
        rows, columns = if original_output.tty?
          IO.console.winsize
        else
          [20, 80]
        end

        str.length <= columns ? str : str[0...(columns-1)] + "…"
      end

      def clock
        @start_at ||= Time.now
        duration = Time.now - @start_at

        minutes = (duration / 60).to_i
        seconds = (duration - minutes * 60).to_i

        "%02d:%02d " % [minutes, seconds]
      end

      def c
        @c ||= Color.new(original_output)
      end
    end
  end
end
