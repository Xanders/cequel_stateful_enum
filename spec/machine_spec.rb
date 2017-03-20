require 'spec_helper'

RSpec.describe CequelStatefulEnum::Machine do
  let(:subject) { Model.new(field: :zero) }

  context 'simple event' do
    it 'changes field on correct model' do
      subject.field = :one
      expect(subject.field).to eq(:one)
      expect(subject.one_to_two).to be_truthy
      expect(subject.field).to eq(:two)
    end

    it 'does not change field on incorrect model' do
      expect(subject.field).to eq(:zero)
      expect(subject.one_to_two).to be_falsey
      expect(subject.field).to eq(:zero)
    end
  end

  context 'bang method' do
    it 'works as non-bang method on correct model' do
      subject.field = :one
      expect(subject.field).to eq(:one)
      expect(subject.one_to_two!).to be_truthy
      expect(subject.field).to eq(:two)
    end

    it 'raises error on incorrect model' do
      expect(subject.field).to eq(:zero)
      expect { subject.one_to_two! }.to raise_error(CequelStatefulEnum::StateError, "can't fire one_to_two event from state zero")
      expect(subject.field).to eq(:zero)
    end

    it 'raises error when conditions does not met' do
      expect { subject.not_if_symbol! }.to raise_error(CequelStatefulEnum::ConditionError, "conditions for not_if_symbol event does not met")
    end
  end

  context 'can method' do
    it 'returns true on correct model' do
      subject.field = :one
      expect(subject.field).to eq(:one)
      expect(subject.can_one_to_two?).to be_truthy
      expect(subject.field).to eq(:one)
    end

    it 'returns false on incorrect model' do
      expect(subject.field).to eq(:zero)
      expect(subject.can_one_to_two?).to be_falsey
      expect(subject.field).to eq(:zero)
    end

    it 'returns false when conditions does not met' do
      expect(subject.can_not_if_symbol?).to be_falsey
    end
  end

  context 'several transitions on one event' do
    it 'works for two-element Hash' do
      expect(subject.field).to eq(:zero)
      expect(subject.one_to_two_and_two_to_three).to be_falsey
      subject.field = :one
      expect(subject.field).to eq(:one)
      expect(subject.one_to_two_and_two_to_three).to be_truthy
      expect(subject.field).to eq(:two)
      expect(subject.one_to_two_and_two_to_three).to be_truthy
      expect(subject.field).to eq(:three)
      expect(subject.one_to_two_and_two_to_three).to be_falsey
    end

    it 'works for two declarations' do
      expect(subject.field).to eq(:zero)
      expect(subject.another_one_to_two_and_two_to_three).to be_falsey
      subject.field = :one
      expect(subject.field).to eq(:one)
      expect(subject.another_one_to_two_and_two_to_three).to be_truthy
      expect(subject.field).to eq(:two)
      expect(subject.another_one_to_two_and_two_to_three).to be_truthy
      expect(subject.field).to eq(:three)
      expect(subject.another_one_to_two_and_two_to_three).to be_falsey
    end

    it 'works for array as key' do
      expect(subject.field).to eq(:zero)
      expect(subject.zero_and_one_to_two).to be_truthy
      expect(subject.field).to eq(:two)
      subject.field = :one
      expect(subject.field).to eq(:one)
      expect(subject.zero_and_one_to_two).to be_truthy
      expect(subject.field).to eq(:two)
      expect(subject.zero_and_one_to_two).to be_falsey
      expect(subject.field).to eq(:two)
    end

    it 'works for several-to-one definition' do
      expect(subject.field).to eq(:zero)
      expect(subject.another_zero_and_one_to_two).to be_truthy
      expect(subject.field).to eq(:two)
      subject.field = :one
      expect(subject.field).to eq(:one)
      expect(subject.another_zero_and_one_to_two).to be_truthy
      expect(subject.field).to eq(:two)
      expect(subject.another_zero_and_one_to_two).to be_falsey
      expect(subject.field).to eq(:two)
    end

    it 'works with `all` declaration' do
      expect(subject.field).to eq(:zero)
      expect(subject.any_to_three).to be_truthy
      expect(subject.field).to eq(:three)
      subject.field = :one
      expect(subject.field).to eq(:one)
      expect(subject.any_to_three).to be_truthy
      expect(subject.field).to eq(:three)
      subject.field = :two
      expect(subject.field).to eq(:two)
      expect(subject.any_to_three).to be_truthy
      expect(subject.field).to eq(:three)
      expect(subject.any_to_three).to be_falsey
      expect(subject.field).to eq(:three)
    end

    it 'works as toggler' do
      subject.field = :one
      expect(subject.field).to eq(:one)
      expect(subject.toggle_one_and_two).to be_truthy
      expect(subject.field).to eq(:two)
      expect(subject.toggle_one_and_two).to be_truthy
      expect(subject.field).to eq(:one)
      expect(subject.toggle_one_and_two).to be_truthy
      expect(subject.field).to eq(:two)
    end
  end

  context '`if` and `unless` conditions' do
    it 'checks and combine positive conditions' do
      %i[if_symbol if_proc not_unless_symbol not_unless_proc if_and_unless].each do |method|
        subject.field = :zero
        expect(subject.field).to eq(:zero)
        expect(subject.send(method)).to be_truthy
        expect(subject.field).to eq(:one)
      end
    end

    it 'checks and combine negative conditions' do
      %i[not_if_symbol not_if_proc unless_symbol unless_proc not_if_and_unless if_and_not_unless not_if_and_not_unless].each do |method|
        expect(subject.field).to eq(:zero)
        expect(subject.send(method)).to be_falsey
        expect(subject.field).to eq(:zero)
      end
    end
  end

  context '`before` and `after` callbacks' do
    it 'works for symbol in `before`' do
      expect(subject).to receive(:callback)
      subject.before_symbol
    end

    it 'works for proc in `before`' do
      expect(subject).to receive(:callback)
      subject.before_proc
    end

    it 'works for several `before`' do
      expect(subject).to receive(:callback_one)
      expect(subject).to receive(:callback_two)
      subject.several_befores
    end

    it 'works for symbol in `after`' do
      expect(subject).to receive(:callback)
      subject.after_symbol
    end

    it 'works for proc in `after`' do
      expect(subject).to receive(:callback)
      subject.after_proc
    end

    it 'works for several `after`' do
      expect(subject).to receive(:callback_one)
      expect(subject).to receive(:callback_two)
      subject.several_afters
    end

    it 'works for both before and after callbacks' do
      expect(subject).to receive(:before_callback)
      expect(subject).to receive(:after_callback)
      subject.before_and_after
    end

    it 'does not call any callbacks when event is impossible' do
      subject.field = :one
      expect(subject).not_to receive(:before_callback)
      expect(subject).not_to receive(:after_callback)
      subject.before_and_after
    end
  end

  context 'checks on definition' do
    it 'raises if method already exists' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :one_to_two do
              transition :one => :two
            end
          end
        end
      end.to raise_error(CequelStatefulEnum::DefinitionError, "one of the one_to_two, one_to_two! or can_one_to_two? methods already defined")
    end

    it 'raises on event duplication' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :some_event do
              transition :zero => :one
            end

            event :some_event do
              transition :one => :two
            end
          end
        end
      end.to raise_error(CequelStatefulEnum::DefinitionError, "event some_event has already been defined")
    end

    it 'raises on transition source duplication' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :zero_to_one_or_two do
              transition :zero => :one
              transition :zero => :two
            end
          end
        end
      end.to raise_error(CequelStatefulEnum::DefinitionError, "duplicate entry: transition from zero to one has already been defined")
    end

    it 'raises on unknown from state' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :bad_event do
              transition :five => :zero
            end
          end
        end
      end.to raise_error(CequelStatefulEnum::DefinitionError, "undefined state five")
    end

    it 'raises on unknown to state' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :bad_event do
              transition :zero => :five
            end
          end
        end
      end.to raise_error(CequelStatefulEnum::DefinitionError, "undefined state five")
    end

    it 'raises on bad if condition' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :bad_event do
              transition :zero => :one, if: 'some string'
            end
          end
        end
      end.to raise_error(ArgumentError, "`if` condition can be nil, Symbol or callable object, but String given")
    end

    it 'raises on bad unless condition' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :bad_event do
              transition :zero => :one, unless: 123
            end
          end
        end
      end.to raise_error(ArgumentError, "`unless` condition can be nil, Symbol or callable object, but Integer given")
    end

    it 'raises on bad before callback' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :bad_event do
              before [:some, 'array']
              transition :zero => :one
            end
          end
        end
      end.to raise_error(ArgumentError, "use Symbol or block for `before` callback")
    end

    it 'raises on bad if condition' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :bad_event do
              transition :zero => :one
              after some: :hash
            end
          end
        end
      end.to raise_error(ArgumentError, "use Symbol or block for `after` callback")
    end

    it 'raises on empty callback' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :bad_event do
              before
              transition :zero => :one
            end
          end
        end
      end.to raise_error(ArgumentError, "use Symbol or block for `before` callback")
    end

    it 'raises on symbol plus block callback' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :bad_event do
              before(:some) {}
              transition :zero => :one
            end
          end
        end
      end.to raise_error(ArgumentError, "use Symbol or block for `before` callback")
    end
  end
end