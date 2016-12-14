module Ruboty
  module Capistrano
    module Actions
      class Deployment < Ruboty::Actions::Base
        include Ruboty::Capistrano::GitHubRepositoryValidator

        attr_reader :role, :branch, :errors

        def initialize(role: , branch:)
          @role = role
          @branch = branch
          @errors = []
        end

        def run
          return unless validates

          deploy
          errors.empty?
        end

        def message_before_deploy
          "#{env}環境の#{role}にBRANCH:#{branch}をdeployします"
        end

        def message_after_deploy
          "#{env}環境の#{role}にBRANCH:#{branch}をdeployしました"
        end

        private

        def env
          Ruboty::Capistrano.config.env
        end

        def repo_path
          Ruboty::Capistrano.config.local_repo_path[role]
        end

        def deploy
          cmd = "cd #{repo_path} && bundle && bundle exec cap #{env} deploy BRANCH=#{branch}"
          out, err, status = Bundler.with_clean_env { Open3.capture3(cmd) }
          return if err.empty?

          Ruboty::Capistrano.logger err
          errors << 'deploy中にエラーが発生しました'
        end
      end
    end
  end
end
