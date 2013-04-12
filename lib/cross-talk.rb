require 'celluloid'

require "cross-talk/version"
require 'cross-talk/manager'
require 'cross-talk/listener'

module Cross
  module Talk
    # Access the Event Manager
    def self.manager
      Celluloid::Actor[:manager] ||= Cross::Talk::Manager.new
    end

    def self.included(base)
      base.send(:include, Listener)
    end
  end
end


