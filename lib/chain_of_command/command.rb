# frozen_string_literal: true

require 'chain_of_command/context'

module ChainOfCommand
  class Command
    attr_accessor :context

    def initialize(context)
      @context = context
    end
    private_class_method :new

    class << self
      attr_reader :commands

      def +(cmd)
        klass = Class.new(Command)
        klass.chain(self)
        klass.chain(cmd)

        return klass
      end

      def chain(command, **args)
        @commands ||= []
        # @default_context[command] = args

        if command.respond_to? :call
          @commands << command
        end
      end

      def validate(context)
        missing_fields = []
        fields.each do |field|
          field_name = field[:field_name]

          if field[:default]
            if !context.respond_to?(field_name) || context[field_name] == nil
              context[field_name] = field[:default]
            end
          else
            if !field[:optional] && (!context.respond_to?(field_name) || context[field_name] == nil)
              missing_fields << field_name
            end
          end

          if field[:validator] && context[field_name]
            result = field[:validator].new.call(context[field_name])
            raise Errors::FieldValidationFailed, { field_name => result.errors.to_h } unless result.success?
            context[field_name] = result.to_h
          end

          if field[:type]
            unless context[field_name].is_a?(field[:type])
              raise Errors::InvalidFieldType.new("Expected the field #{field_name} to be of type #{field[:type]}, got a #{context[field_name].class.name}")
            end
          end
        end

        if missing_fields.size > 0
          raise Errors::InvalidContext.new("Expected the field(s) #{missing_fields.inspect}, to be present")
        end

        # if @context_validator
        #   result = @context_validator.new.call(context.clone)
        #   raise Errors::ContextValidationFailed, result.errors.to_h unless result.success?
        # end
      end


      # Usage:
      # class Cls < ChainOfCommand::Command
      #   context_validator Dry::Validation::Contract
      # end

      # def context_validator(validator)
      #   # raise unless validator.respond_to?(:call)
      #   @context_validator = validator
      # end


      # Usage:
      # class Cls < ChainOfCommand::Command
      #   field :name, optional: true
      #   field :country, default: 'se', validator: Dry::Validation::Contract
      # end

      def field(field_name, options = {})
        field = options.slice(:optional, :default, :validator, :type)
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
          begin
            prev_context = context.clone
            context = command.call(context) || prev_context
          rescue ChainOfCommand::Errors::Skip
            return context
          end
        end

        if self.instance_methods.include? :call
          self.validate(context)

          begin
            prev_context = context.clone
            command = self.new(context)
            context = command.call(context) || prev_context
          rescue ChainOfCommand::Errors::Skip
            return context
          end
        end

        return context
      end

      private

      # def call_command(command, context)
      #   begin
      #     prev_context = context.clone
      #     return command.call(context) || prev_context
      #   rescue ChainOfCommand::Errors::Skip
      #     return context
      #   end
      # end
    end

    def skip!
      raise ChainOfCommand::Errors::Skip
    end
  end
end
