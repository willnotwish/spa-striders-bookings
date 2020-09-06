redis_server = {
  host: 'redis',
  port: 6379,
  db: 0
}

Rails.application.config.session_store :redis_store, servers: redis_server, expires_in: 90.minutes
