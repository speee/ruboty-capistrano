require 'ruboty/capistrano/actions/deploy'
require 'ruboty/capistrano/actions/rollback'
require 'ruboty/capistrano/verification'
require 'ruboty/capistrano/deploy_source'

module Ruboty
  module Handlers
    class Capistrano < Base
      env :LOCAL_REPOSITORY_PATH, 'Deploy用の Repository Path を設定する'

      on(/deploy\s+(.*)\s+(.*)/m, name: 'deploy', description: 'deployする')
      on(/rollback\s+(.*)/m, name: 'rollback', description: 'rollbackする')

      def deploy(message)
        config = Ruboty::Capistrano.config
        role, branch = message.match_data[1..2]
        env = config.env

        Ruboty::Capistrano::Verification.new(
          env: env,
          deploy_source: Ruboty::Capistrano::DeploySource.new(
            repo: config.remote_repo_path[role],
            branch: branch
          )
        ).execute

        message.reply("#{env}環境の#{role}にBRANCH:#{branch}をdeployします")
        Ruboty::Capistrano::Actions::Deploy.new(
          env: env,
          repo_path: config.local_repo_path[role],
          branch: branch,
        ).call
        message.reply("#{env}環境の#{role}にBRANCH:#{branch}をdeploy完了しました")
      rescue => e
        message.reply(e.message)
      end

      def rollback(message)
        Ruboty::Capistrano::Actions::Rollback.new(message).call
      end
    end
  end
end
