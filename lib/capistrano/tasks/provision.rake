# Define empty provision tasks.
# These will be filled in by other recipes that contribute additional
# `before` and `during` tasks.

desc "Install and set up all app prerequisites (assumes Ubuntu 12.04)"
task :provision

namespace :provision do
  desc "Install and set up all app prerequisites for Ubuntu 14.04"
  task :"12_04" do
    invoke "provision"
  end

  desc "Install and set up all app prerequisites for Ubuntu 14.04"
  task :"14_04" do
    invoke "provision"
  end
end
