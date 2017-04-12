require 'spec_helper'

RSpec.describe CequelStatefulEnum::Machine do
  let(:subject) { Model.new(field: :zero) }

  context 'simple event' do
    it 'changes field on correct model' do
      expect(subject.field).to eq(:zero)
      expect(subject.zero_to_one).to be_truthy
      expect(subject.field).to eq(:one)
    end

    it 'does not change field on incorrect model' do
      subject.field = :two
      expect(subject.field).to eq(:two)
      expect(subject.zero_to_one).to be_falsey
      expect(subject.field).to eq(:two)
    end
  end

  context 'transition in non-danger mode' do
    it 'works as method without arguments on correct model' do
      expect(subject.field).to eq(:zero)
      expect(subject.zero_to_one(danger: false)).to be_truthy
      expect(subject.field).to eq(:one)
    end

    it 'does not raise error on incorrect model' do
      subject.field = :two
      expect(subject.field).to eq(:two)
      expect { subject.zero_to_one(danger: false) }.not_to raise_error
      expect(subject.field).to eq(:two)
    end

    it 'does not raise error when conditions does not met' do
      expect { subject.not_if_symbol(danger: false) }.not_to raise_error
    end
  end

  context 'transition in danger mode' do
    it 'works as non-danger method on correct model' do
      expect(subject.field).to eq(:zero)
      expect(subject.zero_to_one(danger: true)).to be_truthy
      expect(subject.field).to eq(:one)
    end

    it 'raises error on incorrect model' do
      subject.field = :two
      expect(subject.field).to eq(:two)
      expect { subject.zero_to_one(danger: true) }.to raise_error(CequelStatefulEnum::StateError, "can't fire zero_to_one event from state two")
      expect(subject.field).to eq(:two)
    end

    it 'raises error when conditions does not met' do
      expect { subject.not_if_symbol(danger: true) }.to raise_error(CequelStatefulEnum::ConditionError, "conditions for not_if_symbol event does not met")
    end
  end

  context 'bang method' do
    it 'works as non-bang method on correct model' do
      expect(subject.field).to eq(:zero)
      expect(subject.zero_to_one!).to be_truthy
      expect(subject.field).to eq(:one)
    end

    it 'raises error on incorrect model' do
      subject.field = :two
      expect(subject.field).to eq(:two)
      expect { subject.zero_to_one! }.to raise_error(CequelStatefulEnum::StateError, "can't fire zero_to_one event from state two")
      expect(subject.field).to eq(:two)
    end

    it 'raises error when conditions does not met' do
      expect { subject.not_if_symbol! }.to raise_error(CequelStatefulEnum::ConditionError, "conditions for not_if_symbol event does not met")
    end
  end

  context 'model savings' do
    it 'saves model by default' do
      expect(subject).to receive(:save)
      expect(subject).not_to receive(:save!)
      subject.zero_to_one
    end

    it 'saves model with true option' do
      expect(subject).to receive(:save)
      expect(subject).not_to receive(:save!)
      subject.zero_to_one(save: true)
    end

    it 'does not save model with false option' do
      expect(subject).not_to receive(:save)
      expect(subject).not_to receive(:save!)
      subject.zero_to_one(save: false)
    end

    it 'does not save model with false option on bang method' do
      expect(subject).not_to receive(:save)
      expect(subject).not_to receive(:save!)
      subject.zero_to_one!(save: false)
    end

    it 'saves model with bang in danger mode' do
      expect(subject).not_to receive(:save)
      expect(subject).to receive(:save!)
      subject.zero_to_one(danger: true)
    end

    it 'saves model with bang on bang method' do
      expect(subject).not_to receive(:save)
      expect(subject).to receive(:save!)
      subject.zero_to_one!
    end

    it 'saves model with true option on bang method' do
      expect(subject).not_to receive(:save)
      expect(subject).to receive(:save!)
      subject.zero_to_one!(save: true)
    end

    it 'returns false if can not save' do
      subject.save = false
      expect(subject.zero_to_one).to be_falsey
    end

    it 'changes field if can not save' do
      subject.save = false
      expect(subject.field).to eq(:zero)
      subject.zero_to_one
      expect(subject.field).to eq(:one)
    end

    it 'raises error if can not save in danger mode' do
      subject.save = false
      expect { subject.zero_to_one(danger: true) }.to raise_error(Model::FakeSaveError)
    end

    it 'changes field if can not save in danger mode' do
      subject.save = false
      expect(subject.field).to eq(:zero)
      subject.zero_to_one(danger: true) rescue nil
      expect(subject.field).to eq(:one)
    end

    it 'raises error if can not save in bang method' do
      subject.save = false
      expect { subject.zero_to_one! }.to raise_error(Model::FakeSaveError)
    end

    it 'changes field if can not save in bang method' do
      subject.save = false
      expect(subject.field).to eq(:zero)
      subject.zero_to_one! rescue nil
      expect(subject.field).to eq(:one)
    end

    it 'works for both parameters together' do
      expect(subject.zero_to_one(danger: true, save: false)).to be_truthy
      subject.field = :zero
      expect(subject.zero_to_one(danger: true, save: true)).to be_truthy
      subject.field = :zero
      expect(subject.zero_to_one(danger: false, save: false)).to be_truthy
      subject.field = :zero
      expect(subject.zero_to_one(danger: false, save: true)).to be_truthy
      subject.field = :zero
      subject.save = false
      expect(subject.zero_to_one(danger: true, save: false)).to be_truthy
      subject.field = :zero
      expect { subject.zero_to_one(danger: true, save: true) }.to raise_error(Model::FakeSaveError)
      subject.field = :zero
      expect(subject.zero_to_one(danger: false, save: false)).to be_truthy
      subject.field = :zero
      expect(subject.zero_to_one(danger: false, save: true)).to be_falsey
    end
  end

  context 'can method' do
    it 'returns true on correct model' do
      expect(subject.field).to eq(:zero)
      expect(subject.can_zero_to_one?).to be_truthy
      expect(subject.can_zero_to_one?(danger: true)).to be_truthy
      expect(subject.can_zero_to_one?(danger: false)).to be_truthy
      expect(subject.field).to eq(:zero)
    end

    it 'returns false on incorrect model' do
      subject.field = :two
      expect(subject.field).to eq(:two)
      expect(subject.can_zero_to_one?).to be_falsey
      expect(subject.can_zero_to_one?(danger: false)).to be_falsey
      expect(subject.field).to eq(:two)
    end

    it 'returns false on model in unknown state' do
      subject.field = :unknown_state
      expect(subject.field).to eq(nil)
      expect(subject.can_zero_to_one?).to be_falsey
      expect(subject.can_zero_to_one?(danger: false)).to be_falsey
      expect(subject.field).to eq(nil)
    end

    it 'returns false when conditions does not met' do
      expect(subject.can_not_if_symbol?).to be_falsey
      expect(subject.can_not_if_symbol?(danger: false)).to be_falsey
    end

    it 'raises error in danger mode on incorrect model' do
      subject.field = :two
      expect(subject.field).to eq(:two)
      expect { subject.can_zero_to_one?(danger: true) }.to raise_error(CequelStatefulEnum::StateError, "can't fire zero_to_one event from state two")
      expect(subject.field).to eq(:two)
    end

    it 'raises error in danger mode on model in unknown state' do
      subject.field = :unknown_state
      expect(subject.field).to eq(nil)
      expect { subject.can_zero_to_one?(danger: true) }.to raise_error(CequelStatefulEnum::StateError, "can't fire zero_to_one event from unknown state nil")
      expect(subject.field).to eq(nil)
    end

    it 'raises error in danger mode when conditions does not met' do
      expect { subject.can_not_if_symbol?(danger: true) }.to raise_error(CequelStatefulEnum::ConditionError, "conditions for not_if_symbol event does not met")
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

    it 'calls before but not after callback when save is not possible' do
      subject.save = false
      expect(subject).to receive(:before_callback)
      expect(subject).not_to receive(:after_callback)
      subject.before_and_after
    end

    it 'calls before but not after callback in bang method when save is not possible' do
      subject.save = false
      expect(subject).to receive(:before_callback)
      expect(subject).not_to receive(:after_callback)
      expect { subject.before_and_after! }.to raise_error(Model::FakeSaveError)
    end

    it 'calls before and after callbacks when save is not possible but disabled' do
      subject.save = false
      expect(subject).to receive(:before_callback)
      expect(subject).to receive(:after_callback)
      subject.before_and_after(save: false)
    end
  end

  context 'checks on definition' do
    it 'raises if method already exists' do
      expect do
        Model.class_eval do
          column :another_field, :enum, values: { zero: 0, one: 1, two: 2 } do
            event :zero_to_one do
              transition :zero => :one
            end
          end
        end
      end.to raise_error(CequelStatefulEnum::DefinitionError, "one of the zero_to_one, zero_to_one! or can_zero_to_one? methods already defined")
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