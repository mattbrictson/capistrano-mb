fiftyfive_recipe :ssl do
  during :provision, "generate_self_signed_crt"
end

namespace :fiftyfive do
  namespace :ssl do
    desc "Generate an SSL key and CSR for Ngnix HTTPS"
    task :generate_csr do
      _run_ssl_script
      _copy_to_all_web_servers(%w(.key .csr))
    end

    desc "Generate an SSL key, CSR, and self-signed cert for Ngnix HTTPS"
    task :generate_self_signed_crt do
      _run_ssl_script("--self")
      _copy_to_all_web_servers(%w(.key .csr .crt))
    end

    def _run_ssl_script(opt="")
      privileged_on primary(:web) do
        files_exist = %w(.key .csr .crt).any? do |ext|
          test("sudo [ -f /etc/ssl/#{application_basename}#{ext} ]")
        end

        if files_exist
          info("Files exist; skipping SSL key generation.")
        else
          config = "/tmp/csr_config"
          ssl_script = "/tmp/ssl_script"

          template("csr_config.erb", config, :sudo => true)
          template("ssl_setup", ssl_script, :mode => "+x", :sudo => true)

          within "/etc/ssl" do
            execute :sudo, ssl_script, opt, application_basename, config
            execute :sudo, "rm", ssl_script, config
          end
        end
      end
    end

    def _copy_to_all_web_servers(extensions)
      # TODO
    end
  end
end
