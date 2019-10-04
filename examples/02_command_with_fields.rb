# frozen_string_literal: true

require 'chain_of_command'

class CommandWithFields < ChainOfCommand::Command
  fields :a_int, :a_string, :a_bool

  def call(context)
    puts "I'm #{self.class.name}"
    puts "Got context #{context}"
    return context
  end
end

CommandWithFields.call(a_int: 1, a_string: "str", a_bool: true)

begin
  CommandWithFields.call
rescue ChainOfCommand::Errors::InvalidContext => e
  puts e.message
end
