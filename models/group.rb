class Group
	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true, :length => (1..50), :unique => true
	property :descr, Text, :required => true, :length => (0..200)

	has n, :profiles, :through => Resource

	def self.new_group(name,description='')
		begin
			p = create(:name => name, :descr => description)
		rescue Exception => e
			puts e.backtrace.inspect
			puts e.message
			p.errors.each do |e|
				puts e
			end
		end
	end

	def self.get_group(name)
		p = first(:name => name)
	end

end
