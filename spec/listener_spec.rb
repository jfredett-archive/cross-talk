require 'spec_helper'


describe Cross::Talk::Listener do

  before :all do
    class Receiver
      include Celluloid
      include Cross::Talk

      listen Sender, :test, :after do |sender|
        @notified = true
      end

      def has_been_notified?
        @notified
      end
    end

    class Sender
      include Celluloid
      include Cross::Talk

      def test
      end

      def late_binding

      end
    end
  end

  after :all do
    Object.send(:remove_const, :Receiver)
    Object.send(:remove_const, :Sender)
  end

  let!(:receiver) { Receiver.new }
  let!(:sender) { Sender.new }

  it 'registers for a notification during class creation' do

  end

  it 'registers for a notification with late-binding' do

  end

  it 'sends an event when executing a public method' do

  end

  it "doesn't send an event when executing a non-public method" do

  end
end
