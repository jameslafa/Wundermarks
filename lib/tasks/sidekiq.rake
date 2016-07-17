class SidekiqUtil

  def self.queues
    ::Sidekiq::Stats.new.queues.keys.map { |name| ::Sidekiq::Queue.new(name) }
  end

  def self.clear_all
    self.queues.each { |q| q.clear }
  end

end

namespace :sidekiq do
  desc "Clear out the every sidekiq queues"
  task clear_all_queues: :environment do |t, args|
    SidekiqUtil.clear_all
  end

  desc "Set timestamp for monitoring"
  task set_timestamp: :environment do
    TestSidekiqJob.perform_later
  end
end
