require 'bundler/setup'

require 'pry'

require 'cross-talk'

require 'coveralls'
Coveralls.wear!

#include helpers
Dir["./spec/helpers/*.rb"].each { |file| require file }

#include shared examples
Dir["./spec/shared/*_examples.rb"].each { |file| require file }

RSpec.configure do |config|
  config.before do
    allow_message_expectations_on_nil
  end

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.extend(RSpec::Cross::Talk::DSL::Macros)
end
