module Ruboty
  module Capistrano
    class Config
      include ActiveSupport::Configurable

      configure do |config|
        config.env = ENV['RUBOTY_ENV']
        config.github_access_token = ENV['GITHUB_ACCESS_TOKEN']
        config.log_path = ENV['DEPLOY_LOG_PATH']
        config.repository_name = ENV['DEPLOY_REPOSITORY_NAME']
        config.repository_path = ENV['DEPLOY_REPOSITORY_PATH'].split(';').inject({}) do |hash, s|
          key, value = s.split(":").first, s.split(":").last
          hash[key] = value
          hash
        end
      end
    end
  end
end
