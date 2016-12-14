require 'ruboty/capistrano/actions/deployment'
require 'ruboty/capistrano/actions/rollback'

module Ruboty
  module Handlers
    class Capistrano < Base
      env :LOCAL_REPOSITORY_PATH, 'Deploy用の Repository Path を設定する'

      on(/deploy\s+(.*)\s+(.*)/m, name: 'deploy', description: 'deployする')
      on(/rollback\s+(.*)/m, name: 'rollback', description: 'rollbackする')

      def deploy(message)
        deployment = Ruboty::Capistrano::Actions::Deployment.new(deploy_params(message))
        message.reply(deployment.message_before_deploy)

        if deployment.run
          message.reply(deployment.message_after_deploy)
        else
          message.reply(deployment.errors.join(','))
        end
      end

      def rollback(message)
        Ruboty::Capistrano::Actions::Rollback.new(message).call
      end

      private

      def deploy_params(message)
        role, branch = message.match_data[1..2]
        { role: role, branch: branch }
      end
    end
  end
end
