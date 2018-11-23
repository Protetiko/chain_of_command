# frozen_string_literal: true

module ChainOfCommand
  module Errors
    Skip             = Class.new(StandardError)
    InvalidContext   = Class.new(StandardError)
  end
end
