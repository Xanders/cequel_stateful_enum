# CequelStatefulEnum

cequel_stateful_enum is a simple state machine gem built on top of [Cequel](https://github.com/cequel/cequel)'s built-in enum column.
This gem is totally based on [stateful_enum](https://github.com/amatsuda/stateful_enum) gem for ActiveRecord. Huge thanks to Akira Matsuda!
This gem in not depends on Rails.


## Installation

Add this line to your app's Gemfile:

```ruby
gem 'cequel_stateful_enum'
```

And bundle.


## Usage

The cequel_stateful_enum gem extends Cequel's `column` definition to take a block with a similar DSL to the [state_machine](https://github.com/pluginaweek/state_machine) gem.

Example:
```ruby
class Bug
  include Cequel::Record

  column :status, :enum, values: { unassigned: 0, assigned: 1, resolved: 2, closed: 3 } do
    event :assign do
      transition :unassigned => :assigned
    end

    event :resolve do
      before do
        self.resolved_at = Time.now
      end

      transition [:unassigned, :assigned] => :resolved
    end

    event :close do
      transition all - [:closed] => :closed

      after :notify_author_about_status

      after do
        BugCache.remove_from_open_cache(self)
      end
    end
  end

  # ...

end
```

### Defining the States

Just call the Cequel's `column` method with `:enum` type. The only difference from the original method is that our `column` call takes a block.

### Defining the Events

You can declare events through `event` method inside of an `column` block. Then cequel_stateful_enum defines the following methods per each event:

**An instance method to fire the event**

```ruby
@bug.assign # does nothing and returns false if a valid transition for the current state is not defined
```

**An instance method with `!` to fire the event**
```ruby
@bug.assign! # raises if a valid transition for the current state is not defined
```

**A predicate method that returns if the event is fireable**
```ruby
@bug.can_assign? # returns if the `assign` event can be called on this bug or not and all `if` and `unless` conditions are met
```

### Defining the Transitions

You can define state transitions through `transition` method inside of an `event` block.

There are a few important details to note regarding this feature:

* The `transition` method takes a Hash each key of which is state "from" transitions to the Hash value.
* The "from" states and the "to" states should both be given in Symbols.
* The "from" state can be multiple states, in which case the key can be given as an Array of states, as shown in the usage example.
* The "from" state can be `all` that means all defined states.

### :if and :unless Condition

The `transition` method takes an `:if` and/or `:unless` option as a Proc or Symbol.

Example:
```ruby
event :assign do
  transition :unassigned => :assigned, if: -> { assigned_to.any? }, unless: :blocked?
end
```

### Event Hooks

You can define `before` and `after` event hooks inside of an `event` block as shown in the example above. Symbols and Proc objects are supported.


## Contributing

Pull requests are welcome on GitHub at https://github.com/Xanders/cequel_stateful_enum.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).