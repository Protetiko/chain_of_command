# frozen_string_literal: true

module ChainOfCommand
  module Errors
    Skip                  = Class.new(StandardError)
    InvalidContext        = Class.new(StandardError)
    InvalidFieldType      = Class.new(StandardError)
    FieldValidationFailed = Class.new(StandardError)
    # ContextValidationFailed = Class.new(StandardError)
  end
end
