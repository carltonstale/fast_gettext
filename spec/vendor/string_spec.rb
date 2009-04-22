current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','spec_helper')

#just to make sure we did not mess up while copying...
describe String do
  it "substitudes using % + Hash" do
    "x%{name}y" %{:name=>'a'}.should == 'xay'
  end

  describe 'old sprintf style' do
    it "substitudes using % + Array" do
      ("x%sy%s" % ['a','b']).should == 'xayb'
    end

    it "does not remove %{} style replacements" do
      ("%{name} x%sy%s" % ['a','b']).should == '%{name} xayb'
    end

    it "does not remove %<> style replacement" do
       ("%{name} %<num>f %s" % ['x']).should == "%{name} %<num>f x"
    end
  end

  describe 'ruby 1.9 style %< replacement' do
    it "subsitutes %<something>d" do
      ("x%<hello>dy" % {:hello=>1}).should == 'x1y'
    end

    it "substitutes #b" do
      ("%<num>#b" % {:num => 1}).should == "0b1"
    end


  end
end