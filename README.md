# Putest

Runs puppet tests.
Outputs fancy report.

Returns 0 on success.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'putest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install putest

## Usage
Test all modules:

    putest -p /etc/puppet/environments

Test all modules in environment *development*:

    putest -p /etc/puppet/environments -e development

Test module *stdlib* in all environments:

    putest -p /etc/puppet/environments -m stdlib

Test module *stdlib* in environment *development*:

    putest -p /etc/puppet/environments -m stdlib -e development
