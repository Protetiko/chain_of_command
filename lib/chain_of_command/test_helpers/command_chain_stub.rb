# frozen_string_literal: true

module ChainOfCommand
  module TestHelpers
    module StubCommandChain
      class CommandStub < ChainOfCommand::Command
        def initialize(context)
          @context = context
        end

        def call(context)
          return @context
        end
      end

      def stub_command(cmd, context, &block)
        @commands.find(cmd) = CommandStub.new(context)
      end
    end
  end
end
