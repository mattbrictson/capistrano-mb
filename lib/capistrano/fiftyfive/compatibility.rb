require 'colorize'

unless defined?(Capistrano) && respond_to?(:namespace)
  $stderr.puts\
    "WARNING: capistrano/fiftyfive must be loaded by Capistrano in order "\
    "to work.\nRequire this gem by using Capistrano's Capfile, "\
    "as described here:\n"\
    "https://github.com/55minutes/capistrano-fiftyfive#installation"\
    .colorize(:red)
end

if Capistrano::VERSION == "3.2.0"
  $stderr.puts\
    "WARNING: Capistrano 3.2.0 has a critical bug that prevents "\
    "capistrano-fiftyfive from working as intended:\n"\
    "https://github.com/capistrano/capistrano/issues/1004".colorize(:red)
end
