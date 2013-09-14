module Cross
  module Talk
    module Listener
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:extend, ClassMethods)
        base.send(:include, Celluloid::Logger)
        base.send(:extend, Celluloid::Logger)

        # This makes sure that when we add a new hook at runtime, we rebuild all
        # of our hooks so that they're up-to-date.
        base.instance_eval do
          listen base, :__new_hook, :before do
            register_hooks!
          end
        end
      end

      module InstanceMethods
        def register_hooks!
          self.class.registration_hooks.each { |hook| hook.call(__get_receiver) }
        end

        def initialize(*_)
          register_hooks!
          super
        end

        def silenced?
          @__silenced
        end

        def silence!
          @__silenced = true
        end

        def unsilence!
          @__silenced = false
        end

        def silently
          silence!
          yield
          unsilence!
        end

        def listen(klass, event, timing, &block)
          event_name = "#{klass}##{event}:#{timing}"
          Cross::Talk.manager.notify('__new_hook:before', event_name)
          define_singleton_method event_name, &block
          Cross::Talk.manager.register(event_name, __get_receiver)
          Cross::Talk.manager.notify('__new_hook:after', event_name)
        end

        private

        def __notify_event(method, timing)
          return if Object.methods.include?(method)
          return unless public_methods(false).include?(method)
          return if silenced?

          receiver = __get_receiver
          event_name = "#{receiver.class}##{method}:#{timing}"

          Cross::Talk.manager.notify(event_name, receiver)
        end

        def __get_receiver
          return Celluloid::Actor.current if is_a?(Celluloid)
          return self
        end
      end

      module ClassMethods
        def registration_hooks
          @registration_hooks ||= []
        end

        def listen(klass, event, timing, &block)
          event_name = "#{klass}##{event}:#{timing}"
          Cross::Talk.manager.notify('__new_hook:before', event_name)
          define_hook! event_name, &block
          registration_hooks << proc { |actor| Cross::Talk.manager.register(event_name, actor) }
          Cross::Talk.manager.notify('__new_hook:after', event_name)
        end

        def notify(method_name)
          class_eval %{
            alias __old_#{method_name} #{method_name}

            def #{method_name}(*args, &block)
              __notify_event(#{method_name.inspect}, :before)
              result = __old_#{method_name}(*args, &block)
              __notify_event(#{method_name.inspect}, :after)
              result
            end
          }

          send(:private, method_name) if private_instance_methods.include?("__old_#{method_name}".to_sym)
          send(:protected, method_name) if protected_instance_methods.include?("__old_#{method_name}".to_sym)

          nil
        end

        def method_added(method)
          # if we're redefining a method, the lock is set to true, so bug out.
          return if @lock
          #don't notify hook methods
          return if method =~ /^.*#.*:.*$/
          # don't notify pseudoprivate methods
          return if method =~ /^__/
          @lock = true
          notify(method)
          @lock = false
        end

        def define_hook!(method, &block)
          define_method(method, &block)
        end
      end
    end
  end
end
