class Model
  include Cequel::Record

  column :field, :enum, values: { zero: 0, one: 1, two: 2, three: 3 } do
    event :one_to_two do
      transition :one => :two
    end

    event :one_to_two_and_two_to_three do
      transition :one => :two, :two => :three
    end

    event :another_one_to_two_and_two_to_three do
      transition :one => :two
      transition :two => :three
    end

    event :zero_and_one_to_two do
      transition [:zero, :one] => :two
    end

    event :another_zero_and_one_to_two do
      transition :zero => :two
      transition :one => :two
    end

    event :any_to_three do
      transition all - [:three] => :three
    end

    event :toggle_one_and_two do
      transition :one => :two, :two => :one
    end

    event :if_symbol do
      transition :zero => :one, :if => :true?
    end

    event :not_if_symbol do
      transition :zero => :one, :if => :false?
    end

    event :if_proc do
      transition :zero => :one, :if => -> { true? }
    end

    event :not_if_proc do
      transition :zero => :one, :if => -> { false? }
    end

    event :unless_symbol do
      transition :zero => :one, :unless => :true?
    end

    event :not_unless_symbol do
      transition :zero => :one, :unless => :false?
    end

    event :unless_proc do
      transition :zero => :one, :unless => -> { true? }
    end

    event :not_unless_proc do
      transition :zero => :one, :unless => -> { false? }
    end

    event :if_and_unless do
      transition :zero => :one, :if => :true?, :unless => -> { false? }
    end

    event :not_if_and_unless do
      transition :zero => :one, :if => -> { false? }, :unless => :false?
    end

    event :if_and_not_unless do
      transition :zero => :one, :if => -> { true? }, :unless => -> { true? }
    end

    event :not_if_and_not_unless do
      transition :zero => :one, :if => :false?, :unless => :true?
    end

    event :before_symbol do
      before :callback
      transition :zero => :one
    end

    event :before_proc do
      before { callback }
      transition :zero => :one
    end

    event :several_befores do
      before :callback_one
      before { callback_two }
      transition :zero => :one
    end

    event :after_symbol do
      transition :zero => :one
      after :callback
    end

    event :after_proc do
      transition :zero => :one
      after { callback }
    end

    event :several_afters do
      transition :zero => :one
      after :callback_one
      after { callback_two }
    end

    event :before_and_after do
      before :before_callback
      transition :zero => :one
      after :after_callback
    end
  end

  def true?
    true
  end

  def false?
    false
  end
end