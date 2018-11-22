require "test_helper"

class ChainOfCommandTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ChainOfCommand::VERSION
  end

  def test_it_define_a_command
    refute_nil ::ChainOfCommand::Command
  end

  def test_it_define_a_chain
    refute_nil ::ChainOfCommand::Chain
  end

  def test_it_define_errors
    refute_nil ::ChainOfCommand::Errors
    refute_nil ::ChainOfCommand::Errors::Skip
    refute_nil ::ChainOfCommand::Errors::Abort
    refute_nil ::ChainOfCommand::Errors::InvalidContext
  end
end
