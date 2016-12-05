require 'ruboty/capistrano/github'

module Ruboty
  module Capistrano
    module Actions
      class Deploy < Ruboty::Actions::Base
        class DeployError < StandardError; end
        class NoBranchError < StandardError; end

        attr_reader :message, :path, :name, :env, :branch, :role

        def initialize(message)
          @message = message
          @env = Ruboty::Capistrano.config.env
          @role = message.match_data[1]
          @path = Ruboty::Capistrano.config.repository_path[@role]
          @name = Ruboty::Capistrano.config.repository_name[@role]
          @branch = message.match_data[2] || ENV['DEFAULT_BRANCH']
          @logger = Logger.new(deploy_log_path)
        end

        def call
          message.reply("#{@env}環境の#{@role}にBRANCH:#{@branch}をdeployします")
          deploy
          message.reply("#{@env}環境の#{@role}にBRANCH:#{@branch}をdeploy完了しました")
        rescue NoBranchError => e
          err_message = <<~TEXT
            :u7121:#{e.message}:u7121:
          TEXT
        rescue => e
          err_message = <<~TEXT
            :cop:問題が発生しました:cop:
          TEXT
          @logger.error e.message
        ensure
          message.reply(err_message)
        end

        private
        def deploy
          if @env == 'production' && @branch != 'master'
            raise InvalidDeploySettingError.new('production環境はmaster以外でdeploy出来ません')
          end

          unless Ruboty::Capistrano::Github.branch_exist?(name, branch)
            raise NoBranchError, "#{role}のリポジトリに#{branch}ブランチは存在しません"
          end

          cmd = "cd #{path} && bundle && bundle exec cap #{@env} deploy BRANCH=#{@branch}"
          out, err, status = Bundler.with_clean_env { Open3.capture3(cmd) }
          @logger.info out
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
