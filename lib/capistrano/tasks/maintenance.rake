fiftyfive_recipe :maintenance do
  # No hooks for this recipe
end

namespace :fiftyfive do
  namespace :maintenance do
    desc "Tell nginx to display a 503 page for all web requests, using the "\
         "maintenance.html.erb template"
    task :enable do
      on roles(:web) do
        reason = ENV["REASON"]
        deadline = ENV["DEADLINE"]

        template "maintenance.html.erb",
                 "#{current_path}/public/system/maintenance.html",
                 :binding => binding,
                 :mode => "644"
      end
    end

    desc "Remove the 503 page"
    task :disable do
      on roles(:web) do
        execute :rm, "-f", "#{current_path}/public/system/maintenance.html"
      end
    end
  end
end
