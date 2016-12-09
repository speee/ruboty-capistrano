module Ruboty
  module Capistrano
    class Verification
      class InvalidDeploySettingError < StandardError; end
      class NoBranchError < StandardError; end

      include ActiveSupport::Rescuable

      rescue_from NoBranchError, with: -> (e) { raise NoBranchError, no_branch_error(e) }
      rescue_from InvalidDeploySettingError, with: -> (e) { raise InvalidDeploySettingError, invalid_deploy_setting_error(e) }

      attr_reader :env, :role, :deploy_source

      def initialize(**args)
        @env = args[:env]
        @role = args[:role]
        @deploy_source = args[:deploy_source]
      end

      def execute
        prod_branch_limit
        exist_branch_check
      rescue => e
        rescue_with_handler(e)
      end

      private

      def prod_branch_limit
        if env == 'production' && deploy_source.branch != 'master'
          raise InvalidDeploySettingError, 'production環境はmaster以外でdeploy出来ません'
        end
      end

      def exist_branch_check
        unless deploy_source.exist_github?
          raise NoBranchError, "#{deploy_source.repo}のリポジトリに#{deploy_source.branch}ブランチは存在しません"
        end
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
