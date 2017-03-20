# frozen_string_literal: true

require 'cequel'
require 'cequel_stateful_enum/machine'

module CequelStatefulEnum
  module Extension
    #   column :status, :enum, values: { opened: 1, closed: 2 } do
    #     event :close do
    #       transition :opened => :closed
    #     end
    #   end
    def column(name, type, options = {}, &block)
      super

      if type == :enum && block
        states = options[:values]
        states = states.keys if states.is_a?(Hash)
        CequelStatefulEnum::Machine.new(self, name, states, &block)
      end
    end
  end
end

Cequel::Record::Properties::ClassMethods.prepend CequelStatefulEnum::Extension