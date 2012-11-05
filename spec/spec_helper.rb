require 'rubygems'
require 'rspec'
require 'simplecov'
require 'dm-core'
require 'dm-do-adapter/spec/shared_spec'
require 'do-hana-adapter'

class ::Garbage
  include ::DataMapper::Resource
   property :id, Serial
   property :title, String
   property :body, Text
   property :word_count, Integer
   property :publish_date, Date
   property :creation_timestamp, DateTime
   property :lunch_break_time, Time
   property :active, Boolean
   property :location_latitude, Float, field: "latitude"
end

class ::Heffalump
  include ::DataMapper::Resource
  
  property :id,        Serial
  property :color,     String
  property :num_spots, Integer
  property :latitude,  Float
  property :striped,   Boolean
  property :created,   DateTime
  property :at,        Time, field: "at_time"
end
   
class ::Mushroom
  include ::DataMapper::Resource
  property :id, Serial
  property :created, DateTime
  property :active, Boolean
end
#ENV['ODBCINI'] = "#{File.dirname(__FILE__)}/odbc.ini" unless ENV['ODBCINI']
