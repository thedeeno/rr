module RR
  module DoubleDefinitions
    module Strategies
      module Scope
        # Calling instance_of will cause all instances of the passed in Class
        # to have the Double defined.
        #
        # The following example mocks all User's valid? method and return false.
        #   mock.instance_of(User).valid? {false}
        #
        # The following example mocks and proxies User#projects and returns the
        # first 3 projects.
        #   mock.instance_of(User).projects do |projects|
        #     projects[0..2]
        #   end        
        class InstanceOfClass < ScopeStrategy
          register "instance_of", "new_instance_of"

          def initialize(*args)
            super

            if !double_definition_create.no_subject? && !double_definition_create.subject.is_a?(Class)
              raise ArgumentError, "instance_of only accepts class objects"
            end
          end

          protected
          def do_call
            instance_of_subject_double_definition_create = DoubleDefinitionCreate.new
            instance_of_subject_double_definition_create.stub(subject)
            instance_of_subject_double_definition_create.call(:new) do |*args|
              add_double_to_instance(subject.allocate, *args)
            end
          end
          
          def add_double_to_instance(instance, *args)
            double_injection = Injections::DoubleInjection.find_or_create_by_subject(instance, method_name)
            Double.new(double_injection, definition)
            #####
            if args.last.is_a?(ProcFromBlock)
              instance.__send__(:initialize, *args[0..(args.length-2)], &args.last)
            else
              instance.__send__(:initialize, *args)
            end
            instance
          end
        end
      end
    end
  end
end