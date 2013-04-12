module Cross
  module Talk
    class Manager
      include Celluloid
      include Celluloid::Logger

      def initialize
        @event_table = {}
      end

      def notify(event, sender)
        receivers_for(event).each do |receiver|
          next unless receiver.respond_to?(event)
          receiver.async.send(event, sender)
        end
      end

      def register(event, receiver)
        receivers_for(event) << receiver
        nil
      end

      private

      attr_reader :event_table

      def receivers_for(event)
        # We need to ||= here to avoid a weird behavior with Hash.new { [] } --
        # you can't destructively update the first element to it.
        event_table[event] ||= Set.new
      end
    end
  end
end
