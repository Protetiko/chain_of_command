# frozen_string_literal: true

require 'chain_of_command/command'

module ChainOfCommand
  class Chain
    def initialize(*commands)
      @command = Class.new(Command)
      commands.each do |cmd|
        chain(cmd)
      end
    end

    def <<(cmd)
      chain(cmd)
    end

    def +(cmd)
      self.class.new(*@command.commands, cmd)
    end

    def commands
      return @command.commands
    end
    
    def chain(cmd)
      @command.chain(cmd)
      self
    end

    def call(context = {})
      return @command.call(context)
    end
  end
end
