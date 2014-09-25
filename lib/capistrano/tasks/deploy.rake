namespace :deploy do
  task :failed do
    output = env.backend.config.output
    output.on_deploy_failure if output.respond_to?(:on_deploy_failure)
  end
end
