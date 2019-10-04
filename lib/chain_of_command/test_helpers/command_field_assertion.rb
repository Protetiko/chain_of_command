# frozen_string_literal: true

module ChainOfCommand
  module TestHelpers
    module FieldAssertion
      def validate(context)
        refute_raises Errors::InvalidContext do
          super(context)
        end
    end
  end
end
