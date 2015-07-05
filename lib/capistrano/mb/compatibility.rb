module Capistrano
  module MB
    module Compatibility
      def self.check
        check_capistrano_and_rake_are_loaded
        check_blacklisted_capistrano_version
      end

      def self.check_capistrano_and_rake_are_loaded
        return if defined?(Capistrano::VERSION) && defined?(Rake)

        warn "capistrano/mb must be loaded by Capistrano in order "\
             "to work.\nRequire this gem by using Capistrano's Capfile, "\
             "as described here:\n"\
             "https://github.com/mattbrictson/capistrano-mb#installation"
      end

      def self.check_blacklisted_capistrano_version
        return unless defined?(Capistrano::VERSION)
        return unless Capistrano::VERSION == "3.2.0"

        warn "Capistrano 3.2.0 has a critical bug that prevents "\
             "capistrano-mb from working as intended:\n"\
             "https://github.com/capistrano/capistrano/issues/1004"
      end

      # We can't really rely on anything being loaded at this point, so define
      # our own basic colorizing helper.
      def self.warn(message)
        return $stderr.puts("WARNING: #{message}") unless $stderr.tty?
        $stderr.puts("\e[0;31;49mWARNING: #{message}\e[0m")
      end
    end
  end
end

Capistrano::MB::Compatibility.check
