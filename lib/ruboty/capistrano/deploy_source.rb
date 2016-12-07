require 'octokit'

module Ruboty::Capistrano
  class DeploySource
    attr_reader :repo, :branch, :client

    def initialize(repo, branch)
      @repo = repo
      @branch = branch
    end

    def exist_github?
      !!client.branch(repo_name, branch)
    rescue Octokit::NotFound
      false
    end

    private

    def client
      @client ||= Octokit::Client.new(access_token: Ruboty::Capistrano.config.github_access_token)
    end
  end
end
