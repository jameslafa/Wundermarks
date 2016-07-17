application_name = Rails.application.class.parent_name.parameterize
Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0', namespace: "#{application_name}_#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0', namespace: "#{application_name}_#{Rails.env}" }
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RetryJobs, max_retries: 5
  end
end
