require 'ostruct'

module ChainOfCommands
  module Errors
    Skip            = Class.new(StandardError)
    Abort           = Class.new(StandardError)
    ValidationError = Class.new(StandardError)
  end

  class Chain
    def self.link(command)
      @commands ||= []
      @commands << command
    end

    def self.perform(params)
      context = OpenStruct.new(params.to_h)
      puts @commands.inspect

      context = @commands.reduce(context) do |context, command|
        next context if @must_abort

        puts "Performing #{command.name}"

        begin
          c = command.new(context)
          c.validate
          c.perform

        rescue Errors::Abort
          @must_abort = true
        rescue Errors::Skip
        end

        next context
      end

      return context
    end
  end

  class Command
    attr_accessor :context

    def initialize(context)
      @context = context
    end

    def perform

    end

    def validate
      validator = self.class.instance_variable_get(:@validator)

      if validator
        puts "Validating #{self.class.name}"
        validation = validator.call(@context)

        raise(Errors::ValidationError, validation.messages) if validation.failure?
      end
    end

    def skip!
      raise Errors::Skip
    end

    def self.perform(params)
      puts "Performing #{self.name}"
      command = self.new(OpenStruct.new(params))
      command.perform
      return command.context
    end

    def self.validator(validator)
      @validator = validator
    end
  end
end


##### Test cases:


class Command1 < ChainOfCommands::Command
  def perform
    puts "Hello from #{self.class.name}"
    context.command1 = 1
    puts "context.param1 == #{context.param1}"
    context.param1 = 1
  end
end

class Command2 < ChainOfCommands::Command
  def perform
    puts "Hello from #{self.class.name}"
    context.command2 = 2
    puts "context.param1 == #{context.param1}"
    context.param1 = 2
  end
end

class MyValidator
  def self.call(context)
    resp = OpenStruct.new("failure?": false, "messages": nil)
    puts context.inspect
    if context.param1 == nil || context.param1 != 2 || !context.to_h.key?(:param2)
      resp['failure?'] = true
      resp.messages = ["There was a failure"];
    end
    return resp
  end
end

class Command3 < ChainOfCommands::Command
  validator MyValidator

  def perform
    puts "Hello from #{self.class.name}"
    context.command3 = 3
    puts "context.param1 == #{context.param1}"
    context.param1 = 3
  end
end

class ExampleChain < ChainOfCommands::Chain
  link Command1
  link Command2
  link Command3
  link Command2
end

class Command4 < ChainOfCommands::Command
  def perform
    puts "Hello from #{self.class.name}"
  end
end

class Chain2 < ChainOfCommands::Chain
  link Command4
  link ExampleChain
end

context = ExampleChain.perform(param1: "param", param2: "param")
puts context
puts Command3.perform(context)
puts context
puts Chain2.perform(context)
