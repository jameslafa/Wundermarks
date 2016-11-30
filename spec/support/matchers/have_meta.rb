# http://code.dblock.org/2013/12/13/custom-rspec-meta-tag-validator.html

class HaveMeta
 attr_accessor :expected_val, :actual_val, :attribute

 def initialize(expected)
   @expected = expected
 end

 def matches?(page)
   @expected.all? do |key, val|
     meta = page.first("meta[name='#{key}'], meta[property='#{key}']", :visible => false)
     self.actual_val = meta ? meta.native.attribute("content").try(:value) : nil
     self.expected_val = val
     self.attribute = key

     meta ? actual_val.include?(expected_val) : false     
   end
 end

 def failure_message
   "expected '#{attribute}' to contain '#{expected_val}' in '#{actual_val}'"
 end

 def failure_message_when_negated
   "expected '#{attribute}' not to contain '#{expected_val}' in '#{actual_val}'"
 end
end

def have_meta(expected)
 HaveMeta.new(expected)
end
