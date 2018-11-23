require 'ostruct'

module ChainReaction
  module Errors
    Skip             = Class.new(StandardError)
    Abort            = Class.new(StandardError)
    ValidationFailed = Class.new(StandardError)
  end

  class Command
    attr_accessor :context
    attr_accessor :command_dept

    class << self
      def has_commands?
        @commands && @commands.length > 0
      end

      def validator(validator)
        @validator = validator
      end

      def link(command)
        @commands ||= []
        @commands << command
      end

      def perform(params = {}, command_root = true)
        context = OpenStruct.new(params.to_h)
        must_abort = false

        context.dept ||= 0
        puts "#{' '*context.dept}#### Executing #{self.name}"
        puts "#{' '*context.dept}#{@commands.inspect}"
        context.dept += 2

        puts "Context: #{context.inspect}"
        context = (@commands || []).reduce(context) do |context, command|
          next context if must_abort

          begin
            if command.has_commands?
              command.perform(context, false)
            end
            c = command.new(context)
            c.validate
            c.perform

          rescue ChainReaction::Errors::Abort
            must_abort = true
          rescue ChainReaction::Errors::Skip
          end

          next context
        end

        if command_root && !must_abort
          begin
            c = self.new(context)
            c.validate
            c.perform

          rescue ChainReaction::Errors::Abort
            must_abort = true
          rescue ChainReaction::Errors::Skip
          end
        end

        raise ChainReaction::Errors::Abort if !command_root && must_abort

        return context
      end
    end

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

        raise(ChainReaction::Errors::ValidationError, validation.messages) if validation.failure?
      end
    end

    def skip!
      puts "SKIP!"
      raise ChainReaction::Errors::Skip
    end

    def abort!
      puts "ABORT!"
      raise ChainReaction::Errors::Abort
    end
  end
end


##### Test cases:


class Command1 < ChainReaction::Command
  def perform
    puts "#{' '*context.dept}Performing #{self.class.name}"
  end
end

class Command2 < ChainReaction::Command
  def perform
    puts "#{' '*context.dept}Performing #{self.class.name}"
    skip!
  end
end

class MyValidator
  def self.call(context)
    resp = OpenStruct.new("failure?": false, "messages": nil)
    if !context.to_h.key?(:param2) || context.param2 == nil
      resp['failure?'] = true
      resp.messages = ["There was a failure"];
    end
    return resp
  end
end

class Command3 < ChainReaction::Command
#  validator MyValidator

  def perform
    puts "#{' '*context.dept}Performing #{self.class.name}"
    abort!
  end
end

class SimpleChain < ChainReaction::Command
  link Command1
  link Command3

  def perform
    puts "#{' '*context.dept}Finishing #{self.class.name}"
  end
end

class ExampleChain < ChainReaction::Command
  link Command1
  link Command2
  link SimpleChain
  link Command3
  link Command2

  def perform
    puts "#{' '*context.dept}Finishing #{self.class.name}"
  end
end

class Command4 < ChainReaction::Command
  def perform
    puts "#{' '*context.dept}Performing #{self.class.name}"
  end
end

class Chain2 < ChainReaction::Command
  link Command4
  link ExampleChain
  link Command4

  def perform
    puts "#{' '*context.dept}Finishing #{self.class.name}"
  end
end

ExampleChain.perform
Command3.perform
Chain2.perform
