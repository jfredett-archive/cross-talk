require 'spec_helper'


describe Cross::Talk::Manager do
  subject(:manager) { Cross::Talk.manager }

  before :all do
    class Receiver
      include Celluloid
      include Celluloid::Logger

      def initialize
        Cross::Talk.manager.register('an_event', Actor.current)
      end

      def an_event(*_)
        @notification = true
      end

      def has_received_notification?
        @notification
      end
    end

    class StupidReceiver
      include Celluloid

      def initialize
        Cross::Talk.manager.register('an_event', Actor.current)
      end

      # I'm dumb because I didn't implement the event method!
    end

    class NonReceiver
      include Celluloid

      def initialize
        Cross::Talk.manager.register('another_event', Actor.current)
      end

      def another_event(*_)
      end
    end
  end

  after :all do
    Object.send(:remove_const, :Receiver)
    Object.send(:remove_const, :NonReceiver)
    Object.send(:remove_const, :StupidReceiver)
  end


  describe 'api' do
    it { should respond_to :notify }
    it { should respond_to :register }
  end

  let!(:receiver) { Receiver.new }
  let!(:non_receiver) { NonReceiver.new }
  let!(:stupid_receiver) { StupidReceiver.new }

  before do
    stupid_receiver.stub(:an_event)
    non_receiver.stub(:an_event)
    manager.notify('an_event', nil)
  end

  it 'notifies registered receivers when an event occurs' do
    receiver.should have_received_notification
  end

  it 'only notifies registered receivers which actually define the event method' do
    stupid_receiver.should_not have_received :an_event
  end

  it 'does not notify receivers of other messages of that message' do
    non_receiver.should_not have_received :an_event
  end
end
