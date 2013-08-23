require "capistrano/fiftyfive"

# Capistrano::Fiftyfive.register_hooks(:ssl) do
# end

Capistrano::Configuration.instance(:must_exist).load do
  namespace :fiftyfive do
    namespace :ssl do

      def prompt(field, example)
        value = Capistrano::CLI.ui.ask("#{field} [#{example}]: ")
        value.empty? ? example : value.to_s
      end

      def run_ssl_script(opt="")
        config = "/tmp/csr_config"
        ssl_script = "/tmp/ssl_script"

        template("csr_config.erb", config)
        template("ssl_setup", ssl_script, :mode => "+x")

        run("cd /etc/ssl && #{sudo} #{ssl_script} #{opt} #{application} #{config}")
        run("rm #{ssl_script} #{config}")
      end

      set_default(:ssl_csr_country) { prompt("Country", "US") }
      set_default(:ssl_csr_state)   { prompt("State", "California") }
      set_default(:ssl_csr_city)    { prompt("City", "Albany") }
      set_default(:ssl_csr_org)     { prompt("Organization", "55 Minutes Inc.") }
      set_default(:ssl_csr_name)    { prompt("Common name", "www.55minutes.com") }

      desc "Generate an SSL key and CSR for Ngnix HTTPS"
      task :generate_csr, :roles => :web, :once => true do
        run_ssl_script
      end

      desc "Generate an SSL key, CSR, and self-signed cert for Ngnix HTTPS"
      task :generate_self_signed_crt, :roles => :web, :once => true do
        run_ssl_script("--self")
      end
    end
  end
end
