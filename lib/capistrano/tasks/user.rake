fiftyfive_recipe :user do
  during :provision, %w(add install_public_key)
end

namespace :fiftyfive do
  namespace :user do
    desc "Create the UNIX user if it doesn't already exist"
    task :add do
      privileged_on roles(:all) do |host, user|
        unless test("grep -q #{user}: /etc/passwd")
          execute :adduser, "--disabled-password", user, "</dev/null"
        end
      end
    end

    desc "Copy root's authorized_keys to the user account if it doesn't "\
         "already have its own keys"
    task :install_public_key do
      privileged_on roles(:all) do |host, user|
        unless test("[ -f /home/#{user}/.ssh/authorized_keys ]")
          execute :mkdir, "-p", "/home/#{user}/.ssh"
          execute :cp, "~/.ssh/authorized_keys", "/home/#{user}/.ssh"
          execute :chown, "-R", "#{user}:#{user}", "/home/#{user}/.ssh"
          execute :chmod, "600", "/home/#{user}/.ssh/authorized_keys"
        end
      end
    end
  end
end
