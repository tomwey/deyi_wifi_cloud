require 'redis'
require 'redis-namespace'
require 'redis/objects'

# require 'sidekiq/web'
# require 'sidekiq/cron/web'
# require 'sidekiq-cron'

redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]

$redis = Redis.new(host: redis_config['host'], port: redis_config['port'])
Redis::Objects.redis = $redis

sidekiq_url = "redis://#{redis_config['host']}:#{redis_config['port']}/0"
Sidekiq.configure_server do |config|
  config.redis = { namespace: 'sidekiq', url: sidekiq_url }
  
  # 添加cron jobs
  schedule_file = "config/schedule.yml"
  # puts 'sssssss'
  if File.exists?(schedule_file) && Sidekiq.server?
    # puts 'ddddddd'
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end
Sidekiq.configure_client do |config|
  config.redis = { namespace: 'sidekiq', url: sidekiq_url }
end