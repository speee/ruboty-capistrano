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

        def cmd
          return @cmd if @cmd
          cmd_ary = []
          cmd_ary << "cd #{repo_path}"
          version_file = "#{repo_path}/.ruby-version"
          if Ruboty::Capistrano.config.rbenv_root && File.exist?(version_file)
            cmd_ary << "RBENV_VERSION=\"$(cat #{version_file})\" rbenv exec bundle"
            cmd_ary << "RBENV_VERSION=\"$(cat #{version_file})\" rbenv exec bundle exec cap #{env} deploy BRANCH=#{branch}"
          else
            cmd_ary << 'bundle'
            cmd_ary << "bundle exec cap #{env} deploy BRANCH=#{branch}"
          end
          @cmd = cmd_ary.join(' && ')
        end

        def deploy
          Ruboty::Capistrano.logger.info("RUN: #{cmd}")
          out, err, status = Bundler.with_clean_env { Open3.capture3(cmd) }
          Ruboty::Capistrano.logger.info(out)
          return if err.empty?

          Ruboty::Capistrano.logger.error(err)
          errors << 'deploy中にエラーが発生しました'
        end
      end
    end
  end
end
