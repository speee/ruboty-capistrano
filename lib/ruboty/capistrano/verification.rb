module Ruboty
  module Capistrano
    class Verification
      class InvalidDeploySettingError < StandardError; end
      class NoBranchError < StandardError; end

      include ActiveSupport::Rescuable

      rescue_from NoBranchError, with: -> (e) { raise NoBranchError, error_message(e, ':u7121:') }
      rescue_from InvalidDeploySettingError, with: -> (e) { raise InvalidDeploySettingError, error_message(e, ':no_entry_sign:') }

      attr_reader :env, :role, :deploy_source

      def initialize(env:, role:, deploy_source:)
        @env = env
        @role = role
        @deploy_source = deploy_source
      end

      def execute
        validate_deploy_branch_for_production
        validate_existence_in_github
      rescue => e
        rescue_with_handler(e)
      end

      private

      def validate_deploy_branch_for_production
        if env == 'production' && deploy_source.branch != 'master'
          raise InvalidDeploySettingError, 'production環境はmaster以外でdeploy出来ません'
        end
      end

      def validate_existence_in_github
        unless deploy_source.exist_github?
          raise NoBranchError, "#{deploy_source.repo}のリポジトリに#{deploy_source.branch}ブランチは存在しません"
        end
      end

      def error_message(e, emoji)
        <<~TEXT
          #{emoji}#{e.message}#{emoji}
        TEXT
      end
    end
  end
end
