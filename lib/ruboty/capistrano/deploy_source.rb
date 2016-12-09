require 'octokit'

module Ruboty::Capistrano
  class DeploySource
    attr_reader :repo, :branch

    def initialize(**args)
      @repo = args[:repo]
      @branch = args[:branch]
    end

    def exist_github?
      !!octokit_client.branch(repo, branch)
    rescue Octokit::NotFound
      false
    end

    private

    def octokit_client
      @octokit_client ||= Octokit::Client.new(access_token: Ruboty::Capistrano.config.github_access_token)
    end
  end
end
