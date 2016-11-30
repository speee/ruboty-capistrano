require 'octokit'

module Ruboty::Capistrano
  class Github
    class << self
      def client
        @client ||= Octokit::Client.new(access_token: Ruboty::Capistrano.config.github_access_token)
      end

      def branch_exist?(branch)
        client.branch(Ruboty::Capistrano.config.repository_name, branch)
        true
      rescue Octokit::NotFound
        false
      end
    end
  end
end
