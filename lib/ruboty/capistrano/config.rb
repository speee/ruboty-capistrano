module Ruboty
  module Capistrano
    class Config
      include ActiveSupport::Configurable

      configure do |config|
        config.env = ENV['RUBOTY_ENV']
        config.repository_path = ENV['DEPLOY_REPOSITORY_PATH'].split(';').inject({}) do |hash, s|
          key, value = s.split(":").first, s.split(":").last
          hash[key] = value
          hash
        end
      end
    end
  end
end
