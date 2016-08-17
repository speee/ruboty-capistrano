module Ruboty
  module Capistrano
    module Actions
      class Deploy < Ruboty::Actions::Base
        class DeployError < StandardError; end

        attr_reader :message, :path, :env, :branch, :role

        def initialize(message)
          @message = message
          @env = Ruboty::Capistrano.config.env
          @role = message.match_data[1]
          @path = Ruboty::Capistrano.config.repository_path[@role]
          @branch = message.match_data[2] || ENV['DEFAULT_BRANCH']
          @logger = Logger.new("#{DateTime.now.strftime('%Y%m%d%H%M')}.log")
        end

        def call
          message.reply("#{@env}環境の#{@role}にBRANCH:#{@branch}をdeployします")
          response = deploy
          @logger.info response
          message.reply("#{@env}環境の#{@role}にBRANCH:#{@branch}をdeploy完了しました")
        rescue => e
          err_message = <<~TEXT
            :cop:問題が発生しました:cop:
            ```
            #{e.message}
            ```
          TEXT
          @logger.error err
          message.reply(err_message)
        end

        private
        def deploy
          if @env == 'production' && @branch != 'master'
            raise InvalidDeploySettingError.new('production環境はmaster以外でdeploy出来ません')
          end

          cmd = "cd #{path} && bundle && bundle exec cap #{@env} deploy BRANCH=#{@branch}"
          out, err, status = Bundler.with_clean_env { Open3.capture3(cmd) }
          raise DeployError.new(err) unless err.empty?
          out
        end
      end
    end
  end
end
