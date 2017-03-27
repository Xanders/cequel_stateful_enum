# frozen_string_literal: true

module CequelStatefulEnum
  Error = Class.new(RuntimeError)
  DefinitionError = Class.new(Error)
  WorkflowError = Class.new(Error)
  StateError = Class.new(WorkflowError)
  ConditionError = Class.new(WorkflowError)

  class Machine
    def initialize(model, column, states, &block)
      @model, @column, @states, @event_names = model, column, states, []
      instance_eval(&block)
    end

    def event(name, &block)
      raise DefinitionError, "event #{name} has already been defined" if @event_names.include? name
      Event.new @model, @column, @states, name, &block
      @event_names << name
    end

    class Event
      def initialize(model, column, states, name, &block)
        can = "can_#{name}?"
        raise DefinitionError, "one of the #{name}, #{name}! or #{can} methods already defined" if ([name, "#{name}!", can] & model.instance_methods).any?

        @states, @name, @transitions, @before, @after = states, name, {}, [], []
        instance_eval(&block) if block

        transitions, before, after = @transitions, @before, @after

        # defining event methods
        model.class_eval do
          define_method name do |save: true, danger: false|
            next false unless send(can, danger: danger)
            to = transitions[send(column).to_sym].first
            before.each { |callback| instance_eval(&callback) }
            send("#{column}=", to)
            if save
              if danger
                save!
              else
                result = self.save
              end
            end
            after.each { |callback| instance_eval(&callback) } unless result == false
            result.nil? ? true : result
          end

          define_method "#{name}!" do |save: true|
            send(name, save: save, danger: true)
          end

          define_method can do |danger: false|
            from = send(column).to_sym
            to, condition = transitions[from]
            if !to
              raise StateError, "can't fire #{name} event from state #{from}" if danger
              false
            elsif condition && !instance_exec(&condition)
              raise ConditionError, "conditions for #{name} event does not met" if danger
              false
            else
              true
            end
          end
        end
      end

      def transition(transitions)
        condition = transitions.delete(:if)
        unless condition.nil? || condition.is_a?(Symbol) || condition.respond_to?(:call)
          raise ArgumentError, "`if` condition can be nil, Symbol or callable object, but #{condition.class} given"
        end
        if condition.is_a?(Symbol)
          symbol = condition
          condition = -> { send(symbol) }
        end
        if unless_condition = transitions.delete(:unless)
          unless unless_condition.nil? || unless_condition.is_a?(Symbol) || unless_condition.respond_to?(:call)
            raise ArgumentError, "`unless` condition can be nil, Symbol or callable object, but #{unless_condition.class} given"
          end
          if unless_condition.is_a?(Symbol)
            symbol = unless_condition
            unless_condition = -> { send(symbol) }
          end
          condition = if condition
            if_condition = condition
            -> { instance_exec(&if_condition) && !instance_exec(&unless_condition) }
          else
            -> { !instance_exec(&unless_condition) }
          end
        end

        transitions.each_pair do |froms, to|
          raise DefinitionError, "undefined state #{to}" unless @states.include? to
          Array(froms).each do |from|
            raise DefinitionError, "undefined state #{from}" unless @states.include? from
            raise DefinitionError, "duplicate entry: transition from #{from} to #{@transitions[from].first} has already been defined" if @transitions[from]
            @transitions[from] = [to, condition]
          end
        end
      end

      def all
        @states
      end

      def before(symbol = nil, &block)
        raise ArgumentError, 'use Symbol or block for `before` callback' unless block_given? ? symbol.nil? : symbol.is_a?(Symbol)
        block ||= -> { send(symbol) }
        @before.push(block)
      end

      def after(symbol = nil, &block)
        raise ArgumentError, 'use Symbol or block for `after` callback' unless block_given? ? symbol.nil? : symbol.is_a?(Symbol)
        block ||= -> { send(symbol) }
        @after.push(block)
      end
    end
  end
end