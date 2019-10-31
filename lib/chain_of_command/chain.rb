# frozen_string_literal: true

require 'chain_of_command/command'

module ChainOfCommand
  class Chain
    def initialize(*args)
      @command = Class.new(Command)
      args.each do |cmd|
        chain(cmd)
      end
    end

    def << (cmd)
      chain(cmd)
    end

    def chain(cmd)
      @command.chain(cmd)
    end

    def call(context = {})
      return @command.call(context)
    end
  end
end
