module Ruboty
  module Capistrano
    module Actions
      class Deploy < Ruboty::Actions::Base
        class DeployError < StandardError; end

        attr_reader :message, :path, :rails_env

        def initialize(message, path)
          @message = message
          @path = path
          @rails_env = ENV['RUBOTY_ENV']
          @branch = message.match_data[1] || ENV['DEFAULT_BRANCH']
        end

        def call
          message.reply("#{@rails_env}環境にBRANCH:#{@branch}をdeployします")
          deploy
          message.reply("#{@rails_env}環境にBRANCH:#{@branch}をdeploy完了しました")
        rescue => e
          err_message = <<~TEXT
            :cop:問題が発生しました:cop:
            ```
            #{e.message}
            ```
          TEXT
          message.reply(err_message)
        end

        private
        def deploy
          cmd = "cd #{path} && bundle && bundle exec cap #{@rails_env} deploy BRANCH=#{@branch}"
          out, err, status = Bundler.with_clean_env { Open3.capture3(cmd) }
          raise DeployError.new(err) unless err.empty?
        end
      end
    end
  end
end
