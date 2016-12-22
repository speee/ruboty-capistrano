require 'open3'
require 'active_support/all'
require 'date'
require 'octokit'
require 'ruboty/capistrano/version'
require 'ruboty/capistrano/github_repository_validators'
require 'ruboty/handlers/capistrano'
require 'ruboty/capistrano/actions/deployment'
require 'ruboty/capistrano/actions/rollback'

module Ruboty
  module Capistrano
    autoload :Config, 'ruboty/capistrano/config'

    def self.config
      @config ||= Ruboty::Capistrano::Config.config
    end

    def self.loggers
      return STDOUT if Ruboty::Capistrano.config.log_path.to_s.empty?
      return @logger if @logger

      log_path = File.join(Ruboty::Capistrano.config.log_path, "#{DateTime.now.strftime('%Y%m%d%H%M')}.log")
      @logger = Logger.new(deploy_log_path)
    end
  end
end
