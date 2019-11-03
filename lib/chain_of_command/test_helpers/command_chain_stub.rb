# frozen_string_literal: true

# Usage:
# class AddressFromLongLat < ChainOfCommand::Command
#   field :long
#   field :lat

#   def call(context)
#     context.address = MapAPI.get_adress(long, lat)
#     return context
#   end
# end

# class Person < ChainOfCommand::Command
#   chain AddressFromLongLat

#   field :address
#   field :name

#   def call(context)
#     puts context
#     return context
#   end
# end

# class PersonTest < MiniTest::Test
#   def setup
#     Person.include ChainOfCommand::TestHelpers::CommandChainStub
#     Person.stub_command(
#       AddressFromLongLat,
#       address: {
#         street: '123 Ocean Drive',
#         city: "Miami Beach",
#         state: "FL",
#         zip: "33139",
#         country: "USA"
#       }
#     )
#   end

#   def test_person
#     #...
#     # AddressFromLongLat.call is never called, and the Ocean Drive address will be returned
#   end
# end

module ChainOfCommand
  module TestHelpers
    module CommandChainStub
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def stub_all
          @commands.each do |command|
            stub_command(command, {})
          end
        end

        def stub_command(cmd, context_data)
          @stub_map ||= {}

          #ap "stub #{cmd} with #{context_data}"

          c = Class.new(cmd)
          c.define_method(:call) { |context|
            context_data.each_pair do |k, v|
              context[k] = v
            end

            return context
          }

          @commands&.map! {|x|
            x == (@stub_map[cmd] || cmd) ? c : x
          }

          @stub_map[cmd] = c
        end
      end
    end
  end
end
