require 'spec_helper'


describe Cross::Talk::Listener do
  before :all do
    class Sender
      include Celluloid
      include Cross::Talk

      def test
      end

      def late
      end

      protected

      def protected_method
      end

      private

      def private_method
      end
    end

    class Receiver
      include Celluloid
      include Cross::Talk

      listen Sender, :test, :after do |sender|
        @notified = true
      end

      listen Sender, :private_method, :after do |sender|
        debug "Should never occur"
        @notified = true
      end

      listen Sender, :protected_method, :after do |sender|
        debug "Should never occur"
        @notified = true
      end

      def has_been_notified?
        @notified
      end
    end
  end
  after :all do
    Object.send(:remove_const, :Receiver)
    Object.send(:remove_const, :Sender)
  end

  let!(:receiver) { Receiver.new }
  let!(:other_receiver) { Receiver.new }
  let!(:sender) { Sender.new }

  subject { receiver }

  context 'late-bound listen' do

    before do
      receiver.listen(Sender, :late, :after) do
        @notified = true
      end
    end

    the(:receiver) { should_not have_been_notified }
    the(:other_receiver) { should_not have_been_notified }

    describe 'when the message is sent' do
      before { sender.late }

      the(:receiver) { should have_been_notified }
      the(:other_receiver) { should_not have_been_notified }
    end
  end

  describe 'define-time bound listen' do
    it { should respond_to :"Sender#test:after" }
    it { should_not have_been_notified }

    describe 'calling the method' do
      before { sender.test }

      it { should have_been_notified }
    end

    describe 'calling a private method on the sender' do
      before { sender.send(:private_method) }

      it { should_not have_been_notified }
    end

    describe 'calling a protected method on the sender' do
      before { sender.send(:protected_method) }

      it { should_not have_been_notified }
    end
  end
end
