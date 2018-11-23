# frozen_string_literal: true

require 'chain_of_command'

class BasicCommand < ChainOfCommand::Command
  def call(context)
    puts "I'm #{self.class.name}"
    context.message = "a message"
    return context
  end
end

context = BasicCommand.call

puts context.message
