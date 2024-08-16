VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = false
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock, :faraday
  config.ignore_localhost = true
  config.default_cassette_options = {
    record: :new_episodes
  }
end
