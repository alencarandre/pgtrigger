# Pgtrigger

Create trigger for postgres using ActiveRecord migration

TODO:
 - Create tests
 - Create reversible method for create_trigger
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pgtrigger'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install pgtrigger

## Usage

Create a migration like this

```ruby
class AddTriggerToSomeTable < ActiveRecord::Migration[5.1]
  def up
    create_trigger(:table_name, :increase_order, before: [:insert, :update], declare: {var_1: "text := 'test'", var_2: :integer}) do
        <<-TRIGGERSQL
            var_2 := -1

            NEW."order" := (
              SELECT COALESCE(MAX("order"), 0) +1
              FROM table_name
            );

          RETURN NEW;
        TRIGGERSQL
    end
  end

  def down
    remove_trigger(:table_name, :increase_order)
  end
end
```

The create_trigger method, the first and second parameters are about table and name of trigger respectively.
The third params can be hashes ```before:``` or ```after:```, passing string or array to indicate what event this trigger it will be executed.
The param ```declare:``` is used to declare variables

**NOTE:** Yet is necessary to specify the down method, otherwise the trigger cannot be removed when execute migration rollback.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pgtrigger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

I appreciate new collaborators for this project.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pgtrigger project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alencarandre/pgtrigger/blob/master/CODE_OF_CONDUCT.md).
