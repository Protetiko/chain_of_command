require "test_helper"

class ChainOfCommandTest < Minitest::Test
  def test_basic_command
    cmd = Class.new(ChainOfCommand::Command) {
      def call(context)
        context.val = true unless context.val
        return context
      end
    }

    context = cmd.call
    assert_equal true, context.val

    context = cmd.call(val: "text")
    assert_equal "text", context.val
  end

  def test_basic_chain
    cmd1 = Class.new(ChainOfCommand::Command) {
      def call(context)
        context.cmd1 = true
        return context
      end
    }

    cmd2 = Class.new(ChainOfCommand::Command) {
      def call(context)
        context.cmd2 = true
        return context
      end
    }

    chain = ChainOfCommand::Chain.new
    chain << cmd1
    chain << cmd2
    context = chain.call

    assert context.cmd1
    assert context.cmd2
  end
end


