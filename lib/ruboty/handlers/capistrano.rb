require 'open3'
require "ruboty/capistrano/actions/deploy"

module Ruboty
  module Handlers
    class Capistrano < Base
      env :DEPLOY_REPOSITORY_PATH, 'Deploy用の Repository Path を設定する'

      on(/deploy\s+(.*)/m, name: 'deploy', description: 'deployする')

      def deploy(message)
        Ruboty::Capistrano::Actions::Deploy.new(message, path).call
      end

      def path
        ENV['DEPLOY_REPOSITORY_PATH']
      end
    end
  end
end
