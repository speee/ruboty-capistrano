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
        config.remote_repo_path = extract.call(ENV['REMOTE_REPOSITORY_PATH'])
        config.local_repo_path = extract.call(ENV['LOCAL_REPOSITORY_PATH'])
        config.rbenv_root = ENV['RBENV_ROOT']
      end
    end
  end
end
