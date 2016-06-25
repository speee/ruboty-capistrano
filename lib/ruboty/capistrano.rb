require 'open3'
require 'active_support/all'
require 'ruboty/capistrano/version'
require 'ruboty/handlers/capistrano'

module Ruboty
  module Capistrano
    autoload :Config, 'ruboty/capistrano/config'

    def self.config
      @config ||= Ruboty::Capistrano::Config.config
    end
  end
end
