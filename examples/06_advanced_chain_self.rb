# frozen_string_literal: true

require 'chain_of_command'

class AddOneToCounter < ChainOfCommand::Command
  field :counter

  def call(context)
    puts "Adding 1"
    context.counter += 1
    return context
  end
end

class AddTwoToCounter < ChainOfCommand::Command
  field :counter

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

class AddSevenToCounter < ChainOfCommand::Command
  chain AddFourToCounter
  chain self
  chain AddTwoToCounter

  def call(context)
    puts "Adding 1 through self"
    context.counter += 1
    return context
  end
end

chain = ChainOfCommand::Chain.new(AddTwoToCounter, AddFourToCounter)
chain << AddSevenToCounter
context = chain.call(counter: 0)
if context.success?
  puts "Counter: #{context.counter}"
end
