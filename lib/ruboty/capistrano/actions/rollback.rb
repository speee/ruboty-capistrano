module Ruboty
  module Capistrano
    module Actions
      class Rollback < Ruboty::Actions::Base
        class RollbackError < StandardError; end

        attr_reader :message, :path, :env, :role

        def initialize(message)
          @message = message
          @env = Ruboty::Capistrano.config.env
          @role = message.match_data[1]
          @path = Ruboty::Capistrano.config.local_repo_path[@role]
        end

        def call
          message.reply("#{@env}環境の#{@role}をrollbackします")
          rollback
          message.reply("#{@env}環境の#{@role}をrollback完了しました")
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
        def rollback
          cmd = "cd #{path} && bundle && bundle exec cap #{@env} deploy:rollback"
          out, err, status = Bundler.with_clean_env { Open3.capture3(cmd) }
          raise RollbackError.new(err) unless err.empty?
        end
      end
    end
  end
end
