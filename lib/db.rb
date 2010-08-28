require 'rubygems'
require 'dm-core'
require 'dm-validations'

DataMapper.setup( :default, "sqlite3:///home/wilya/globauth/auth.db" )

require_relative '../models/profile'
require_relative '../models/group'

DataMapper.finalize

DataMapper::Model.raise_on_save_failure = true

