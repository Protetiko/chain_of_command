# frozen_string_literal: true

require 'ostruct'

module ChainOfCommand
  class Command
    class << self
      attr_reader :commands

      def chain(command)
        @commands ||= []
        if command.respond_to? :call
          @commands << command
        end
      end

      def validate(context)
        missing_fields = []
        (@fields || []).each do |field|
          unless context.respond_to? field
            missing_fields << field
          end
        end

        if missing_fields.size > 0
          raise Errors::InvalidContext.new("Expected the field(s) #{missing_fields.inspect}, to be present")
        end
      end

      def fields(*fields)
        @fields = fields
      end

      def call(context = {})
        if context.kind_of? Hash
          context = OpenStruct.new(context.to_h)
        end

        commands = @commands&.clone || []

        commands&.each do |command|
          context = call_command(command, context)
        end

        if self.instance_methods.include? :call
          self.validate(context)
          context = call_command(self.new, context)
        end

        return context
      end

      private

      def call_command(command, context)
        begin
          prev_context = context.clone
          return command.call(context) || prev_context
        rescue ChainOfCommand::Errors::Skip
          return context
        end
      end
    end

    def skip!
      puts "SKIP!"
      raise ChainOfCommand::Errors::Skip
    end

    def abort!
      puts "ABORT!"
      raise ChainOfCommand::Errors::Abort
    end
  end
end
