module Ruboty
  module Capistrano
    class Config
      include ActiveSupport::Configurable

      extract = lambda do |env_str|
        env_str.split(';').inject({}) do |hash, s|
          key, value = s.split(":").first, s.split(":").last
          hash[key] = value
          hash
        end
      end

      configure do |config|
        config.env = ENV['RUBOTY_ENV']
        config.github_access_token = ENV['GITHUB_ACCESS_TOKEN']
        config.log_path = ENV['DEPLOY_LOG_PATH']
        config.repository_name = extract.call(ENV['DEPLOY_REPOSITORY_NAME'])
        config.repository_path = extract.call(ENV['DEPLOY_REPOSITORY_PATH'])
      end
    end
  end
end
