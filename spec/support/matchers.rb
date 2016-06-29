RSpec::Matchers.define :contains_attributes_from do |expected|
  match do |actual|
    actual.attributes.slice(*expected.stringify_keys.keys) == expected.stringify_keys
  end
end
