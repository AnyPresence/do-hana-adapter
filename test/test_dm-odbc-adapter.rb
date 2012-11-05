require 'helper'

class TestHanaAdapter < Test::Unit::TestCase
  
  should "create an instance of HanaAdapter successfully" do
    @adapter = DataMapper.setup(:default, :adapter => 'hana',:hostname  => 'localhost',:port => 2020)
    @adapter.class.name.should eq 'DataMapper::Adapters::HanaAdapter'
  end
  
end
