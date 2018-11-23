# frozen_string_literal: true

require 'chain_of_command'

class Command1 < ChainOfCommand::Command
  def call(context)
    puts "Performing #{self.class.name}"
    context.message = "a message"
    return context
  end
end

class Command2 < ChainOfCommand::Command
  def call(context)
    puts "Performing #{self.class.name}"
    skip!
  end
end

class Command3 < ChainOfCommand::Command
  fields :message

  def call(context)
    puts "Performing #{self.class.name}"
    #abort!
  end
end

class SimpleChain < ChainOfCommand::Command
  chain Command1
  chain Command3

  def call(context)
    puts "Finishing #{self.class.name}"
  end
end

class ExampleChain < ChainOfCommand::Command
  chain Command1
  chain Command1
  chain Command1
  chain Command2
  chain SimpleChain
  chain Command3
  chain Command2

  def call(context)
    puts "Finishing #{self.class.name}"
  end
end

class DisplayContext < ChainOfCommand::Command
  def call(context)
    puts "I'm #{self.class.name}"
    puts "  context: #{context.inspect}"
    puts "  message: #{context.message.inspect}"
    return context
  end
end

class AddToContext < ChainOfCommand::Command
  def call(context)
    puts "I'm #{self.class.name}"
    puts "  context: #{context.inspect}"
    context.field = "a new field"
    puts "  added:   { field: \"#{context.field}\" }"
    return context
  end
end

class AdditionalModifier < ChainOfCommand::Command
  def call(context)
    puts "I'm #{self.class.name}"
    puts "  context:  #{context.inspect}"
    context.message[:c] = "c"
    puts "  modified: { message.c: \"#{context.message[:c]}\" }"

    return context
  end
end

class ModifyContext < ChainOfCommand::Command
  chain AdditionalModifier

  def call(context)
    puts "I'm #{self.class.name}"
    puts "  context:  #{context.inspect}"
    context.field = "modified field"
    puts "  modified: { field: \"#{context.field}\" }"

    return context
  end
end

class ChainWithContext < ChainOfCommand::Command
  chain DisplayContext
  chain AddToContext
  chain Command2
  chain ModifyContext

  def call(context)
    puts "I'm #{self.class.name}, and I got context: #{context.inspect}"
  end
end

class Command4 < ChainOfCommand::Command
  def call(context)
    puts "Performing #{self.class.name}"
  end
end

class ExampleChain2 < ChainOfCommand::Command
  chain Command4
  chain ExampleChain
  chain Command4

  def call(context)
    puts "Finishing #{self.class.name}"
  end
end

class CommandThatAborts < ChainOfCommand::Command
  def call(context)
    puts "I'm #{self.class.name}, and now I will abort!"
    abort!
  end
end

class CommandWithManyFields < ChainOfCommand::Command
  fields :a, :b, :c

  def call(context)

  end
end

puts "# ExampleChain"
ExampleChain.call

puts "\n# ChainOfCommand::Chain.new"
chain = ChainOfCommand::Chain.new
chain << ExampleChain
chain.call

puts "\n# ExampleChain2"
ExampleChain2.call

puts "\n# Command3"
Command3.call(message: "the message")

puts "\n# ChainWithContext"
ChainWithContext.call(message: {a: 'a', b: 'b', c: { d: 'd', e: 'e'}}, keep: true)

begin
  puts "\nCommandThatAborts"
  CommandThatAborts.call
rescue ChainOfCommand::Errors::Abort => e
  puts "  I was aborted!"
end


begin
  puts "\nCommandWithManyFields"
  CommandWithManyFields.call
rescue ChainOfCommand::Errors::InvalidContext => e
  puts "  Had missing fields"
  puts e.message
end
