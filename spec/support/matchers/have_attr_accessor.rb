RSpec::Matchers.define :have_attr_accessor do |field|
  match do |object_instance|
    object_instance.respond_to?(field) &&
      object_instance.respond_to?("#{field}=")
  end

  failure_message_for_should do |object_instance|
    "expected attr_accessor for #{field} on #{object_instance}"
  end

  failure_message_for_should_not do |object_instance|
    "expected attr_accessor for #{field} not to be defined on #{object_instance}"
  end

  description do
    "checks to see if there is an attr accessor on the supplied object"
  end
end
