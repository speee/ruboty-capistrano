module Ruboty::Capistrano
  module GitHubRepositoryValidator
    def self.included(klass)
      raise 'wrong include error' unless klass.ancestors.include?(Ruboty::Actions::Base)
    end

    def validates
      !!github_client.branch(repo, branch)
    rescue Octokit::NotFound => e
      errors << e.message
      false
    end

    private

    def github_client
      Octokit::Client.new(access_token: Ruboty::Capistrano.config.github_access_token)
    end

    def repo
      Ruboty::Capistrano.config.remote_repo_path[role]
    end
  end
end
