# frozen_string_literal: true

require 'chain_of_command'

class AddOneToCounter < ChainOfCommand::Command
  fields :counter

  def call(context)
    puts "Adding 1"
    context.counter += 1
    return context
  end
end

class AddTwoToCounter < ChainOfCommand::Command
  fields :counter

  def call(context)
    puts "Adding 2"
    context.counter += 2
    return context
  end
end

class AddFourToCounter < ChainOfCommand::Command
  chain AddTwoToCounter
  chain AddTwoToCounter
end

class AddEightToCounter < ChainOfCommand::Command
  fields :counter
  chain AddTwoToCounter
  chain AddTwoToCounter
  chain AddOneToCounter

  def call(context)
    puts "Adding the remainder (3)"
    context.counter += 3
    return context
  end
end



chain = ChainOfCommand::Chain.new(AddTwoToCounter, AddFourToCounter)
chain << AddEightToCounter
chain << AddOneToCounter
context = chain.call(counter: 0)
if context.success?
  puts "Counter: #{context.counter}"
end
