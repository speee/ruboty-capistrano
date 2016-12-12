module Ruboty
  module Capistrano
    module Actions
      class Deploy < Ruboty::Actions::Base
        class DeployError < StandardError; end

        attr_reader :repo_path, :env, :branch, :logger, :log_path

        def initialize(env:, repo_path:, branch:, log_path: './tmp')
          @env = env
          @repo_path = repo_path
          @branch = branch
          @logger = Logger.new(log_path)
        end

        def call
          deploy
        rescue => e
          logger.error e.message
          raise e, unknown_error
        end

        private

        def deploy
          cmd = "cd #{repo_path} && bundle && bundle exec cap #{env} deploy BRANCH=#{branch}"
          out, err, status = Bundler.with_clean_env { Open3.capture3(cmd) }
          logger.info out
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
