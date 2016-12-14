module Ruboty
  module Capistrano
    module Actions
      class Deployment < Ruboty::Actions::Base
        attr_reader :role, :branch

        def initialize(role: , branch:)
          @role = role
          @branch = branch
          @errors = []
        end

        def run
          deploy
        rescue => e
          logger.error e.message
          errors << ':cop:問題が発生しました:cop:'
        end

        private

        def env
          Ruboty::Capistrano.config.env
        end

        def repo_path
          Ruboty::Capistrano.config.local_repo_path[role]
        end

        def logger
          @logger ||= Logger.new(deploy_log_path)
        end

        def deploy
          cmd = "cd #{repo_path} && bundle && bundle exec cap #{env} deploy BRANCH=#{branch}"
          out, err, status = Bundler.with_clean_env { Open3.capture3(cmd) }
          raise DeployError.new(err) unless err.empty?
        end

        def deploy_log_path
          return STDOUT if Ruboty::Capistrano.config.log_path.to_s.empty?
          File.join(Ruboty::Capistrano.config.log_path, "#{DateTime.now.strftime('%Y%m%d%H%M')}.log")
        end
      end
    end
  end
end
