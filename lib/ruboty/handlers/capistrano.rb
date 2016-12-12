require 'ruboty/capistrano/actions/deploy'
require 'ruboty/capistrano/actions/rollback'
require 'ruboty/capistrano/verification'
require 'ruboty/capistrano/deploy_source'

module Ruboty
  module Handlers
    class Capistrano < Base
      env :DEPLOY_REPOSITORY_PATH, 'Deploy用の Repository Path を設定する'

      on(/deploy\s+(.*)\s+(.*)/m, name: 'deploy', description: 'deployする')
      on(/rollback\s+(.*)/m, name: 'rollback', description: 'rollbackする')

      def deploy(message)
        role = message.match_data[1]
        env = Ruboty::Capistrano.config.env
        branch = message.match_data[2] || ENV['DEFAULT_BRANCH']
        Ruboty::Capistrano::Verification.new(
          env: env,
          role: role,
          deploy_source: Ruboty::Capistrano::DeploySource.new(
            repo: Ruboty::Capistrano.config.repository_name[role],
            branch: branch
          )
        ).execute
        Ruboty::Capistrano::Actions::Deploy.new(
          message: message,
          env: env,
          role: role,
          repo_path: Ruboty::Capistrano.config.repository_path[role],
          branch: branch,
          log_path: Ruboty::Capistrano.config.log_path.to_s
        ).call
      rescue => e
        message.reply(e.message)
      end

      def rollback(message)
        Ruboty::Capistrano::Actions::Rollback.new(message).call
      end
    end
  end
end
