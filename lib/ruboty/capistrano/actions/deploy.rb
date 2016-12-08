require 'ruboty/capistrano/verification'
require 'ruboty/capistrano/deploy_source'

module Ruboty
  module Capistrano
    module Actions
      class Deploy < Ruboty::Actions::Base
        include ActiveSupport::Rescuable

        class DeployError < StandardError; end

        attr_reader :message, :path, :repo, :env, :branch, :role, :logger

        rescue_from Ruboty::Capistrano::Verification::NoBranchError, with: -> (e) { notify_error(e, no_branch_error(e)) }
        rescue_from Ruboty::Capistrano::Verification::InvalidDeploySettingError, with: -> (e) { notify_error(e, invalid_deploy_setting_error(e)) }

        def initialize(message)
          @message = message
          @env = Ruboty::Capistrano.config.env
          @role = message.match_data[1]
          @path = Ruboty::Capistrano.config.repository_path[@role]
          @repo = Ruboty::Capistrano.config.repository_name[@role]
          @branch = message.match_data[2] || ENV['DEFAULT_BRANCH']
          @logger = Logger.new(deploy_log_path)
        end

        def call
          message.reply("#{@env}環境の#{@role}にBRANCH:#{@branch}をdeployします")
          verify
          deploy
          message.reply("#{@env}環境の#{@role}にBRANCH:#{@branch}をdeploy完了しました")
        rescue => e
          rescue_with_handler(e) || notify_error(e, unknown_error)
        end

        private

        def verify
          verification = Ruboty::Capistrano::Verification.new(
            env: env,
            role: role,
            deploy_source: Ruboty::Capistrano::DeploySource.new(repo, branch)
          )
          verification.prod_branch_limit
          verification.exist_branch_check
        end

        def deploy
          cmd = "cd #{path} && bundle && bundle exec cap #{@env} deploy BRANCH=#{@branch}"
          out, err, status = Bundler.with_clean_env { Open3.capture3(cmd) }
          @logger.info out
          raise DeployError.new(err) unless err.empty?
        end

        def deploy_log_path
          return STDOUT if Ruboty::Capistrano.config.log_path.to_s.empty?

          File.join(Ruboty::Capistrano.config.log_path, "#{DateTime.now.strftime('%Y%m%d%H%M')}.log")
        end

        def notify_error(e, notify_text)
          logger.error e.message
          message.reply(notify_text)
        end

        def unknown_error
          <<~TEXT
            :cop:問題が発生しました:cop:
          TEXT
        end

        def no_branch_error(e)
          <<~TEXT
            :u7121:#{e.message}:u7121:
          TEXT
        end

        def invalid_deploy_setting_error(e)
          <<~TEXT
           :no_entry_sign:#{e.message}:no_entry_sign:
          TEXT
        end
      end
    end
  end
end
