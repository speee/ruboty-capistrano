require 'ruboty/capistrano/github'

module Ruboty
  module Capistrano
    class Verification
      class InvalidDeploySettingError < StandardError; end
      class NoBranchError < StandardError; end

      attr_reader :env, :role, :repo, :branch

      def initialize(**args)
        @env = args[:env]
        @role = args[:role]
        @repo = args[:repo]
        @branch = args[:branch]
      end

      def prod_branch_limit
        if env == 'production' && branch != 'master'
          raise InvalidDeploySettingError, 'production環境はmaster以外でdeploy出来ません'
        end
      end

      def exist_branch_check
        unless Ruboty::Capistrano::Github.branch_exist?(repo, branch)
          raise NoBranchError, "#{role}のリポジトリに#{branch}ブランチは存在しません"
        end
      end
    end
  end
end
