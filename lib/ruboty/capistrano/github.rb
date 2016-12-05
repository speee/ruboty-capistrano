require 'octokit'

module Ruboty::Capistrano
  class Github
    class << self
      def client
        @client ||= Octokit::Client.new(access_token: Ruboty::Capistrano.config.github_access_token)
      end

      def branch_exist?(repo_name, branch)
        client.branch(repo_name, branch)
        true
      rescue Octokit::NotFound
        false
      end
    end
  end
end
