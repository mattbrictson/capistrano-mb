# Capistrano 3.0 unfortunately only runs its :symlink tasks on the :app role,
# which is insufficient. So we have to redefine our own versions of these
# tasks that will run on all other roles.
#
# TODO: remove this recipe once this issue is fixed in Capistrano, and change
# the gemspec to require that version.

fiftyfive_recipe :symlink do
  during "deploy:check:linked_dirs", "check_linked_dirs"
  during "deploy:check:linked_files", "check_linked_files"
  during "deploy:check:make_linked_dirs", "make_linked_dirs"
  during "deploy:symlink:linked_dirs", "linked_dirs"
  during "deploy:symlink:linked_files", "linked_files"
end

namespace :fiftyfive do
  namespace :symlink do

    desc 'Check directories to be linked exist in shared'
    task :check_linked_dirs do
      next unless any? :linked_dirs
      next unless (roles(:all) - roles(:app)).any?
      on (roles(:all) - roles(:app)) do
        execute :mkdir, '-pv', linked_dirs(shared_path)
      end
    end

    desc 'Check directories of files to be linked exist in shared'
    task :make_linked_dirs do
      next unless any? :linked_files
      next unless (roles(:all) - roles(:app)).any?
      on (roles(:all) - roles(:app)) do |host|
        execute :mkdir, '-pv', linked_file_dirs(shared_path)
      end
    end

    desc 'Check files to be linked exist in shared'
    task :check_linked_files do
      next unless any? :linked_files
      next unless (roles(:all) - roles(:app)).any?
      on (roles(:all) - roles(:app)) do |host|
        linked_files(shared_path).each do |file|
          unless test "[ -f #{file} ]"
            error t(:linked_file_does_not_exist, file: file, host: host)
            exit 1
          end
        end
      end
    end

    desc 'Symlink linked directories'
    task :linked_dirs do
      next unless any? :linked_dirs
      next unless (roles(:all) - roles(:app)).any?
      on (roles(:all) - roles(:app)) do
        execute :mkdir, '-pv', linked_dir_parents(release_path)

        fetch(:linked_dirs).each do |dir|
          target = release_path.join(dir)
          source = shared_path.join(dir)
          unless test "[ -L #{target} ]"
            if test "[ -d #{target} ]"
              execute :rm, '-rf', target
            end
            execute :ln, '-s', source, target
          end
        end
      end
    end

    desc 'Symlink linked files'
    task :linked_files do
      next unless any? :linked_files
      next unless (roles(:all) - roles(:app)).any?
      on (roles(:all) - roles(:app)) do
        execute :mkdir, '-pv', linked_file_dirs(release_path)

        fetch(:linked_files).each do |file|
          target = release_path.join(file)
          source = shared_path.join(file)
          unless test "[ -L #{target} ]"
            if test "[ -f #{target} ]"
              execute :rm, target
            end
            execute :ln, '-s', source, target
          end
        end
      end
    end
  end
end
