class Profile
	include DataMapper::Resource

	property :id, Serial
	property :user, String, :required => true, :unique => true, :length => (1..50)
	property :reg_date, Date, :required => true
	property :pass, String, :required => true, :length => (1..50)
	property :email, String, :required => true, :unique => true, :length => (1..50), :format => :email_address
	property :content, Text, :required => true, :length => (0..200)

	has n, :groups, :through => Resource

	def self.new_user(user,pass, email, description = '')
		begin
			p = create(:user => user, :pass => pass, :reg_date => Time.now, :content => description, :email => email)
		rescue Exception => e
			e.backtrace.inspect
			e.message
			p.errors.each do |e|
				puts e
			end
		end
	end

	def self.get_user(user,pass)
		p = first(:user => user, :pass => pass)
	end

end
