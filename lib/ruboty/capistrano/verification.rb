module Ruboty
  module Capistrano
    class Verification
      class InvalidDeploySettingError < StandardError; end
      class BranchNotFoundError < StandardError; end
      class NoBranchError < StandardError; end

      attr_reader :env, :role, :deploy_source

      def initialize(env:, role:, deploy_source:)
        @env = env
        @role = role
        @deploy_source = deploy_source
      end

      def execute
        validate_deploy_branch_for_production
        validate_branch_specified
        validate_existence_in_github
      end

      private

      def validate_deploy_branch_for_production
        if env == 'production' && deploy_source.branch != 'master'
          raise InvalidDeploySettingError, ':no_entry_sign:production環境はmaster以外でdeploy出来ません:no_entry_sign:'
        end
      end

      def validate_branch_specified
        if deploy_source.branch.blank?
          raise NoBranchError, ':u7121:ブランチが指定されていません:u7121:'
        end
      end

      def validate_existence_in_github
        unless deploy_source.exist_github?
          raise BranchNotFoundError, ":u7121:#{deploy_source.repo}のリポジトリに#{deploy_source.branch}ブランチは存在しません:u7121:"
        end
      end
    end
  end
end
