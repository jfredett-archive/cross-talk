require 'celluloid'

require "cross-talk/version"
require 'cross-talk/manager'

module Cross
  module Talk
    # Access the Event Manager
    def self.manager
      Celluloid::Actor[:manager] ||= Cross::Talk::Manager.new
    end
  end
end


