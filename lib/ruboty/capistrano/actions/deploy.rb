module Ruboty
  module Capistrano
    module Actions
      class Deploy < Ruboty::Actions::Base
        class DeployError < StandardError; end

        attr_reader :message, :repo_path, :env, :branch, :role, :logger, :log_path

        def initialize(message:, env:, role:, repo_path:, branch:, log_path: './tmp')
          @message = message
          @env = env
          @role = role
          @repo_path = repo_path
          @branch = branch
          @logger = Logger.new(log_path)
        end

        def call
          message.reply("#{@env}環境の#{@role}にBRANCH:#{@branch}をdeployします")
          deploy
          message.reply("#{@env}環境の#{@role}にBRANCH:#{@branch}をdeploy完了しました")
        rescue => e
          logger.error e.message
          raise e, unknown_error
        end

        private

        def deploy
          cmd = "cd #{path} && bundle && bundle exec cap #{@env} deploy BRANCH=#{@branch}"
          out, err, status = Bundler.with_clean_env { Open3.capture3(cmd) }
          @logger.info out
          raise DeployError.new(err) unless err.empty?
        end

        def deploy_log_path
          return STDOUT if log_path.empty?

          File.join(log_path, "#{DateTime.now.strftime('%Y%m%d%H%M')}.log")
        end

        def unknown_error
          <<~TEXT
            :cop:問題が発生しました:cop:
          TEXT
        end
      end
    end
  end
end
