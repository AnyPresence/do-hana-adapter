require 'spec_helper'

require 'dm-core/spec/shared/adapter_spec'
require 'dm-do-adapter/spec/shared_spec'

require 'dm-migrations'

ENV['ADAPTER'] = 'hana'
ENV['ADAPTER_SUPPORTS'] = 'all'

describe DataMapper::Adapters::HanaAdapter do
  
  before :all do
   
   # Uncomment this line to see all the magical debugging goodness
   #DataMapper::Logger.new(STDOUT, :debug)
   @adapter = DataMapper.setup(:default, :adapter => 'hana', :host => 'imdbhdb', :username => ENV['USERNAME'], :password => ENV['PASSWORD'])   
   DataMapper.auto_migrate!
   @test_objects = []
   @today = Date.today
   @now = Time.now
   @timestamp = DateTime.now
   @id = 8888
   @test_objects << Garbage.create(:title => "Test Article", :body => "This is my very first HANA article", :word_count => 256, :active => false, 
                                :publish_date => @today, :lunch_break_time => @now, :creation_timestamp =>@now, :location_latitude => 99.8712)
      
  end
  
  let(:adapter) { @adapter }
  let(:repository) { DataMapper.repository(@adapter.name) }
  
  after :all do
    Garbage.destroy
    Heffalump.destroy
    Mushroom.destroy
  end
  
  # The first spec tests for an empty insert, which isn't supported by HANA and fails like so:
  
  #insert into odbc.test() values ()
  #[S1000][unixODBC][SAP AG][LIBODBCHDB SO][HDB] General error;257 sql syntax error: incorrect syntax near ")": line 1 col 23 (at pos 23)
  
  #
  #

  #it_should_behave_like 'An Adapter'
  #it_should_behave_like 'A DataObjects Adapter
  
  describe '#create' do
    
    it 'should not raise any errors' do
        lambda {
          Heffalump.create(:color => 'peach')
        }.should_not raise_error
    end

    it 'should set the identity field for the resource' do
        heffalump = Heffalump.new(:color => 'peach')
        heffalump.id.should be_nil
        heffalump.save
        heffalump.id.should_not be_nil
    end
      
    it "should successfully create a resource and persist it to a HANA instance" do
      futter = Mushroom.new
      futter.active = true
      futter.created = Time.now
      futter.raise_on_save_failure = true
      futter.id.should be_nil
      futter.save
      futter.id.should_not be_nil
      futter.id.should be_a_kind_of(Numeric)
    end
    
    it "should do stuff" do
      garbage = Garbage.new(:title => "Hello", :body => "World!", :publish_date => @today, :active => false,  :lunch_break_time => @now, :creation_timestamp =>@timestamp)
      garbage.raise_on_save_failure = true
      garbage.id.should be_nil
      garbage.save
      garbage.id.should be_a_kind_of(Numeric)
      garbage.publish_date.should == @today
      garbage.lunch_break_time.should == @now
      garbage.creation_timestamp.should == @timestamp
      garbage.active.should be_false
    end
    
    it "should create a resource and not overrite a user defined id" do
      article = Garbage.new(:id => @id)
      article.save
      article.id.should == @id
    end
    
    it "should handle time conversion properly " do
      @right_now = Time.now
      article = Garbage.new(:lunch_break_time => @right_now)
      article.save
      article.id.should_not be_nil
      article.lunch_break_time.should == @right_now
    end
    
  end
  
  describe '#read' do
      before :all do
        @heffalump = Heffalump.create(:color => 'brownish hue')
        #just going to borrow this, so I can check the return values
        @query = Heffalump.all.query
      end

      it 'should not raise any errors' do
        lambda {
          Heffalump.all()
        }.should_not raise_error
      end

      it 'should return stuff' do
        Heffalump.all.should be_include(@heffalump)
      end
  end

  describe '#update' do
      before do
        @heffalump = Heffalump.create(:color => 'indigo')
      end

      it 'should not raise any errors' do
        lambda {
          @heffalump.color = 'violet'
          @heffalump.save
        }.should_not raise_error
      end

      it 'should not alter the identity field' do
        id = @heffalump.id
        @heffalump.color = 'violet'
        @heffalump.save
        @heffalump.id.should == id
      end

      it 'should update altered fields' do
        @heffalump.color = 'violet'
        @heffalump.save
        Heffalump.get(*@heffalump.key).color.should == 'violet'
      end

      it 'should not alter other fields' do
        color = @heffalump.color
        @heffalump.num_spots = 3
        @heffalump.save
        Heffalump.get(*@heffalump.key).color.should == color
      end
  end
  
  describe '#delete' do
      before do
        @heffalump = Heffalump.create(:color => 'forest green')
      end

      it 'should not raise any errors' do
        lambda {
          @heffalump.destroy
        }.should_not raise_error
      end

      it 'should delete the requested resource' do
        id = @heffalump.id
        @heffalump.destroy
        Heffalump.get(id).should be_nil
      end
  end
  
  
  describe 'query matching' do
      require 'dm-core/core_ext/symbol'

      before :all do
        @red = Heffalump.create(:color => 'red')
        @two = Heffalump.create(:num_spots => 2)
        @five = Heffalump.create(:num_spots => 5)
      end

      describe 'conditions' do
        describe 'eql' do
          it 'should be able to search for objects included in an inclusive range of values' do
            Heffalump.all(:num_spots => 1..5).should be_include(@five)
          end

          it 'should be able to search for objects included in an exclusive range of values' do
            Heffalump.all(:num_spots => 1...6).should be_include(@five)
          end

          it 'should not be able to search for values not included in an inclusive range of values' do
            Heffalump.all(:num_spots => 1..4).should_not be_include(@five)
          end

          it 'should not be able to search for values not included in an exclusive range of values' do
            Heffalump.all(:num_spots => 1...5).should_not be_include(@five)
          end
        end

        describe 'not' do
          it 'should be able to search for objects with not equal value' do
            Heffalump.all(:color.not => 'red').should_not be_include(@red)
          end

          it 'should include objects that are not like the value' do
            Heffalump.all(:color.not => 'black').should be_include(@red)
          end

          it 'should be able to search for objects with not nil value' do
            Heffalump.all(:color.not => nil).should be_include(@red)
          end

          it 'should not include objects with a nil value' do
            Heffalump.all(:color.not => nil).should_not be_include(@two)
          end

          it 'should be able to search for objects not included in an array of values' do
            Heffalump.all(:num_spots.not => [ 1, 3, 5, 7 ]).should be_include(@two)
          end

          it 'should be able to search for objects not included in an array of values' do
            Heffalump.all(:num_spots.not => [ 1, 3, 5, 7 ]).should_not be_include(@five)
          end

          it 'should be able to search for objects not included in an inclusive range of values' do
            Heffalump.all(:num_spots.not => 1..4).should be_include(@five)
          end

          it 'should be able to search for objects not included in an exclusive range of values' do
            Heffalump.all(:num_spots.not => 1...5).should be_include(@five)
          end

          it 'should not be able to search for values not included in an inclusive range of values' do
            Heffalump.all(:num_spots.not => 1..5).should_not be_include(@five)
          end

          it 'should not be able to search for values not included in an exclusive range of values' do
            Heffalump.all(:num_spots.not => 1...6).should_not be_include(@five)
          end
        end

        describe 'like' do
          it 'should be able to search for objects that match value' do
            Heffalump.all(:color.like => '%ed').should be_include(@red)
          end

          it 'should not search for objects that do not match the value' do
            Heffalump.all(:color.like => '%blak%').should_not be_include(@red)
          end
        end

	# HANA does not have Regex support
        #describe 'regexp' do
        #end

        describe 'gt' do
          it 'should be able to search for objects with value greater than' do
            Heffalump.all(:num_spots.gt => 1).should be_include(@two)
          end

          it 'should not find objects with a value less than' do
            Heffalump.all(:num_spots.gt => 3).should_not be_include(@two)
          end
        end

        describe 'gte' do
          it 'should be able to search for objects with value greater than' do
            Heffalump.all(:num_spots.gte => 1).should be_include(@two)
          end

          it 'should be able to search for objects with values equal to' do
            Heffalump.all(:num_spots.gte => 2).should be_include(@two)
          end

          it 'should not find objects with a value less than' do
            Heffalump.all(:num_spots.gte => 3).should_not be_include(@two)
          end
        end

        describe 'lt' do
          it 'should be able to search for objects with value less than' do
            Heffalump.all(:num_spots.lt => 3).should be_include(@two)
          end

          it 'should not find objects with a value less than' do
            Heffalump.all(:num_spots.gt => 2).should_not be_include(@two)
          end
        end

        describe 'lte' do
          it 'should be able to search for objects with value less than' do
            Heffalump.all(:num_spots.lte => 3).should be_include(@two)
          end

          it 'should be able to search for objects with values equal to' do
            Heffalump.all(:num_spots.lte => 2).should be_include(@two)
          end

          it 'should not find objects with a value less than' do
            Heffalump.all(:num_spots.lte => 1).should_not be_include(@two)
          end
        end
      end

      describe 'limits' do
        it 'should be able to limit the objects' do
          Heffalump.all(:limit => 2).length.should == 2
        end
      end
    end
end
