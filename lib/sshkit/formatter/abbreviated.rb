require 'io/console'
require 'term/ansicolor'

module SSHKit
  module Formatter
    class Abbreviated < SSHKit::Formatter::Abstract
      def initialize(io)
        super

        @log_file = fetch(:fiftyfive_log_file) || "capistrano.log"
        @log_file_formatter = SSHKit::Formatter::Pretty.new(
          ::Logger.new("log/capistrano.log", 1, 20971520)
        )
      end

      def write(obj)
        unless log_started?
          original_output << "Using abbreviated format. " +
                             "Full cap output is being written to " +
                             c.blue(@log_file) + ".\n"
        end

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

        if new_command?(command) && ! command.started?
          original_output << command_description(command) + "\n"
        elsif command.finished?
          original_output << command_status_message(command) + "\n"
        end
      end

      def write_log_message(log_message)
        return unless log_message.verbosity > SSHKit::Logger::INFO
        original_output << log_message
      end

      def command_description(command)
        rows, columns = if original_output.tty?
          IO.console.winsize
        else
          [20, 80]
        end

        width = columns - 6

        desc = command.to_s
        if desc.length > width
          desc = desc[0...(width-1)] + "…"
        end

        clock + c.yellow(desc)
      end

      def command_status_message(command)
        prefix = "     "
        host = c.blue(command.host.to_s)
        elapsed = c.faint(sprintf("%5.3fs", command.runtime))

        status = if command.failure?
          c.red('✘ (see log/capistrano.log for details)')
        else
          c.green("✔")
        end

        [prefix, status, host, elapsed].join(" ")
      end

      def clock
        @start_at ||= Time.now
        duration = Time.now - @start_at

        minutes = (duration / 60).to_i
        seconds = (duration - minutes * 60).to_i

        c.faint("%02d:%02d " % [minutes, seconds])
      end

      def c
        @c ||= Term::ANSIColor
      end

      def new_command?(command)
        if @last_commmand_s == command.to_s
          false
        else
          @last_commmand_s = command.to_s
          true
        end
      end

      def log_started?
        if @log_started
          true
        else
          @log_started = true
          false
        end
      end
    end
  end
end
