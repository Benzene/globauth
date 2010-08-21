require 'rubygems'
require 'dm-core'
require 'dm-validations'

DataMapper.setup( :default, "sqlite3://#{Dir.pwd}/auth.db" )

require 'models/profile'
require 'models/group'

DataMapper.finalize

DataMapper::Model.raise_on_save_failure = true

