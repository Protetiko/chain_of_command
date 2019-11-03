# frozen_string_literal: true

require 'chain_of_command/context'

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
        (fields || []).each do |field|
          if field[:default]
            if !context.respond_to?(field[:field_name]) || context[field[:field_name]] == nil
              context[field[:field_name]] = field[:default]
            end
          else
            if !field[:optional] && (!context.respond_to?(field[:field_name]) || context[field[:field_name]] == nil)
              missing_fields << field[:field_name]
            end
          end
        end

        if missing_fields.size > 0
          raise Errors::InvalidContext.new("Expected the field(s) #{missing_fields.inspect}, to be present")
        end
      end

      # Usage:
      # class Cls < ChainOfCommand::Command
      #   field :name, optional: true
      #   field :country, default: 'se'
      # end

      def field(field_name, options = {})
        field = options.slice(:optional, :default)
        field[:field_name] = field_name
        fields << field
      end

      def fields
        @fields ||= []
      end

      def call(context = {})
        if !context.kind_of?(ChainOfCommand::Context) && (context.kind_of?(Hash) || context.respond_to?(:to_h))
          context = Context.new(context.to_h)
        end

        context['success?'] = true unless context.respond_to?(:success?)

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
      raise ChainOfCommand::Errors::Skip
    end
  end
end
