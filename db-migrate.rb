#!/usr/bin/env ruby

require 'db'

require 'dm-migrations'
DataMapper.auto_migrate!
