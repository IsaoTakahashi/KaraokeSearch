require 'spec_helper'

describe First do
    it "should print 1st" do
        expect(First.new.puts).to be_instance_of String
    end
end
