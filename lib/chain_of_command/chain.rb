# frozen_string_literal: true

require 'chain_of_command/command'

module ChainOfCommand
  class Chain
    attr_reader :command

    def initialize(*args)
      @command = Class.new(Command)
      args.each do |command|
        chain(command)
      end
    end

    def << (command)
      chain(command)
    end

    def chain(command)
      @command.chain(command)
    end

    def call(context = {})
      return @command.call(context)
    end
  end
end
