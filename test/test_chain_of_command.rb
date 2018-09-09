require 'test_helper'

class ChainOfCommandTest < Minitest::Test
  def setup

  end

  def test_single_command
    SimpleCommand.perform
  end

  def test_single_command_with_params
    SimpleCommand.perform(test: "data")
  end
end

class BenchmarkTest < Minitest::Test

end
