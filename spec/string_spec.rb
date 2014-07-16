require 'string'

describe String do
  it "should quote Strings" do
    'foo'.quoted.should eql('"foo"')
  end

  it "should know if a String is quoted" do
    'foo'.quoted?.should eql(false)
    '"foo"'.quoted?.should eql(true)
  end
end
