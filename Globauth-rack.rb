require_relative 'lib/db'

class Globauth
  def initialize(app)
    @app = app
  end

  def call(env)

    # Setup everything so we have access to env and params easily
    @env = env
	puts "Env : #{@env}"
	@request = Rack::Request.new(env)
	puts "Request : #{@request}"
	@params = @request.params
	puts "Params : #{@params}"
	
	# Three possible cases are possible :
	# - We are already authed. Check cookie/session
	puts "Session id : #{@env['rack.session']['uid']}"
	if @env['rack.session']['uid'] && @env['rack.session']['user'] && @env['rack.session']['groups'] then
		puts "Already authed user !"
	
	# - We are authing. Check POST method + login/pass in params
	elsif @env['REQUEST_METHOD'] = "POST" && @params['wUser'] && @params['wPass'] then
		puts "User #{@params['wUser']} is trying to authenticate with pass : #{@params['wPass']}"
		p = Profile.get_user(@params['wUser'],@params['wPass'])
		if p then
			puts 'Authing was successful !'
			@env['rack.session']['uid'] = p.id
			@env['rack.session']['user'] = p.user
			@env['rack.session']['groups'] = Hash.new
			p.groups.each do |g|
				@env['rack.session']['groups'][g.name] = g.descr
			end
		end

	# - Else, we are unauthed
	else
		@env['rack.session'] = Hash.new
	end
	
	# If everything is all right, we call the app
	status, headers, response = @app.call(env)
	
	# We then need to tweak response to add authentication-related boxes on the final page
	puts "Status #{status}"
	puts "Headers #{headers}"
	puts "Response #{response}"

	if @env['rack.session']['uid'] && @env['rack.session']['user'] && @env['rack.session']['groups'] then
		lgbox="Authed as #{@env['rack.session']['user']}"
	else
		lgbox="<form method=\"post\" action=\"\"><input type=\"text\" content=\"User\" name=\"wUser\"/><input type=\"text\" content=\"Pass\" name=\"wPass\"/><input type=\"submit\" /></form>"
	end

	puts response.first.sub!('<div id="loginbox">','<div id="loginbox">' << lgbox)
    
	[status, headers, ["Lol" << response.first]]
  end
end
