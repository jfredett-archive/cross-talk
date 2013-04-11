# Cross::Talk -- Event Pub/Sub for PORC

## Design Notes

At require-time, create a `Cross::Talk::Manager` instance (a singleton). This
serves as the clearinghouse for all events. It is a celluloid actor.

NB. Though cross-talk is perfectly happy to run on MRI, you'll probably have
performance issues unless you run on RBX/JRuby, because we are likely sending
_lots_ of messages at any given point in time, and that means we're probably
eating a lot of CPU cycles.

Every public method call triggers and asynchronous notification to the
`Cross::Talk::Manager` (henceforth, `CTM`). Containing the method invoked, the
object that invoked it, and `:before` or `:after` (depending on which side of
the method you're on).

Another class can subscribe to any event by simply using the class macro
`#listen`, a la:


    class Foo
      include Celluloid::Actor
      include Celluloid::Logger
      include Cross::Talk

      def bar
        info "baz"
      end
    end

    class Listener
      include Celluloid::Actor
      include Celluloid::Logger
      include Cross::Talk

      listen Foo, :bar, :before do
        info "before Foo#bar"
      end

      listen "Foo#bar:after" do |obj|
        info "Calling terminate! on Foo instance"
        obj.terminate!
      end
    end


    Listener.new
    Foo.new.bar

    #=> before Foo#bar
    #=> baz
    #=> Calling terminate! on Foo instance
    #=> <Celluloid::Actor Foo Terminated>

(mod output formatting).


