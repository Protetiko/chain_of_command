# frozen_string_literal: true

require 'chain_of_command'

class CommandA < ChainOfCommand::Command
  fields :initial_val

  def call(context)
    puts "I'm #{self.class.name}"
    context.val_a = context.initial_val + 2
    return context
  end
end

class CommandB < ChainOfCommand::Command
  fields :val_a

  def call(context)
    puts "I'm #{self.class.name}"
    context.val_b = context.val_a + 4
    return context
  end
end

class RootCommand < ChainOfCommand::Command
  chain CommandA
  chain CommandB

  def call(context)
    puts "I'm #{self.class.name}"
    puts "Got values:"
    puts "  #{context.initial_val}"
    puts "  #{context.val_a}"
    puts "  #{context.val_b}"
    context.root_val = context.val_b + 8

    return context
  end
end

context = RootCommand.call(initial_val: 1)
puts "Finally: #{context.root_val}"
