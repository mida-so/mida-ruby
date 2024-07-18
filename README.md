# Mida.so - Server-side A/B Testing and Feature Flags for Ruby

This is a Ruby gem that allows you to integrate with the Mida platform for server-side A/B testing and feature flags.

## Prerequisites

Before using this gem, make sure you have the following set up:

- Ruby installed on your machine
- A Mida.so account with project and experiment key

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mida'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install mida
```

## Usage

To use the server-side A/B testing and feature flags code, follow these steps:

1. Require the `Mida` class in your code:

```ruby
require 'mida'
```

2. Create an instance of the `Mida` class by providing your Mida project key:

```ruby
mida = Mida.new('YOUR_PROJECT_KEY')
```

### A/B Testing

3. Use the `get_experiment` method to retrieve the current version of an experiment for a user:

```ruby
experiment_key = 'EXPERIMENT_KEY'
distinct_id = 'USER_DISTINCT_ID'
version = mida.get_experiment(experiment_key, distinct_id)

if version == 'Control'
  # Handle Control logic
elsif version == 'Variant 1'
  # Handle Variant 1 logic
elsif version == 'Variant 2'
  # Handle Variant 2 logic
end
```

4. Use the `set_event` method to log an event for a user:

```ruby
event_name = 'EVENT_NAME'
distinct_id = 'USER_DISTINCT_ID'
mida.set_event(event_name, distinct_id)
```

For revenue tracking, you can use the `set_event` method with the event name as 'Purchase' and include additional attributes:

```ruby
event_name = 'Purchase'
distinct_id = 'USER_DISTINCT_ID'
properties = {
  revenue: 99.99,
  quantity: 1,
  currency: 'USD'
}
mida.set_event(event_name, distinct_id, properties)
```

### User Attributes

5. Use the `set_attribute` method to set user attributes for a specific user:

```ruby
distinct_id = 'USER_DISTINCT_ID'
attributes = {
  gender: 'male',
  company_name: 'Apple Inc'
}
mida.set_attribute(distinct_id, attributes)
```

### Feature Flags

6. Use the `feature_enabled?` method to check if a feature flag is enabled for the current user:

```ruby
feature_flag_key = 'FEATURE_FLAG_KEY'
is_enabled = mida.feature_enabled?(feature_flag_key)

if is_enabled
  # Feature flag is enabled, perform corresponding actions
else
  # Feature flag is disabled, perform alternative actions
end
```

7. Use the `on_feature_flags` method to reload the feature flags for the current user:

```ruby
mida.on_feature_flags
```

## API Reference

### `Mida.new(project_key, options = {})`
- `project_key`: (required) Your Mida project key.
- `options`: (optional) A hash of additional options.

### `get_experiment(experiment_key, distinct_id)`
- `experiment_key`: (required) The key of the experiment you want to get the version of.
- `distinct_id`: (required) The distinct ID of the user.

Returns the version of the experiment.

### `set_event(event_name, distinct_id, properties = {})`
- `event_name`: (required) The name of the event you want to log.
- `distinct_id`: (required) The distinct ID of the user.
- `properties`: (optional) A hash containing additional event properties.

### `set_attribute(distinct_id, properties)`
- `distinct_id`: (required) The distinct ID of the user.
- `properties`: (required) A hash containing the attribute key-value pairs.

### `feature_enabled?(key)`
- `key`: (required) The key of the feature flag you want to check.

Returns a boolean indicating whether the feature flag is enabled or not.

### `on_feature_flags(distinct_id = nil)`
- `distinct_id`: (optional) The distinct ID of the user.

Reloads the feature flags for the current user.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/mida-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/yourusername/mida-ruby/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
