module Ruboty
  module Capistrano
    class Verification
      class InvalidDeploySettingError < StandardError; end
      class NoBranchError < StandardError; end

      attr_reader :env, :role, :deploy_source

      def initialize(**args)
        @env = args[:env]
        @role = args[:role]
        @deploy_source = args[:deploy_source]
      end

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
    end
  end
end
