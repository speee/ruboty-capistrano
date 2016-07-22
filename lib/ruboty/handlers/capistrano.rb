require "ruboty/capistrano/actions/deploy"

module Ruboty
  module Handlers
    class Capistrano < Base
      env :DEPLOY_REPOSITORY_PATH, 'Deploy用の Repository Path を設定する'

      on(/deploy\s+(.*)\s+(.*)/m, name: 'deploy', description: 'deployする')
      on(/rollback\s+(.*)/m, name: 'rollback', description: 'rollbackする')

      def deploy(message)
        Ruboty::Capistrano::Actions::Deploy.new(message).call
      end

      def rollback(message)
        Ruboty::Capistrano::Actions::Rollback.new(message).call
      end
    end
  end
end
