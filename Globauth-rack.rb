require_relative 'lib/db'

class Globauth
  def initialize(app)
    @app = app
  end

  def call(env)
  
	@request_method_reinit = false

    # Setup everything so we have access to env and params easily
	@request = Rack::Request.new(env)
	@params = @request.params
	
	# Three possible cases are possible :
	# - We are already authed. Check cookie/session
	if env['rack.session']['uid'] && env['rack.session']['user'] && env['rack.session']['groups'] then

		# Do we want to logout ?
			if env['REQUEST_METHOD'] == 'GET' && @params['logout'] == 'true' then
				env['rack.session.options'][:drop] = true
				return [200, {'Content-Type' => 'text/html'}, ['<html><head><meta http-equiv="Refresh" content="1;URL="' << env['PATH_INFO'] << '"></head><body>Deconnection effectuee. Redirection en cours</body></html>'] ]
			end
	
	# - We are authing. Check POST method + login/pass in params
	elsif env['REQUEST_METHOD'] == 'POST' && @params['wUser'] && @params['wPass'] then
		p = repository (:globauth) { Profile.get_user(@params['wUser'],@params['wPass']) }
		if p then
			env['rack.session']['uid'] = p.id
			env['rack.session']['user'] = p.user
			env['rack.session']['groups'] = Hash.new
			p.groups.each do |g|
				env['rack.session']['groups'][g.name] = g.descr
			end
		end
		@request_method_reinit = true

	# - Else, we are unauthed
	else
		env['rack.session'] = Hash.new
	end
	
	# If we changed something, set request-method back to get
	if @request_method_reinit then
		env['REQUEST_METHOD'] = 'GET'
		# We also need to delete the params we used, but how ?
	end

	# If everything is all right, we call the app
	status, headers, response = @app.call(env)
	

	# We then need to tweak response to add authentication-related boxes on the final page

	# If authed, we want to know as who
	if env['rack.session']['uid'] && env['rack.session']['user'] && env['rack.session']['groups'] then
		lgbox="Authed as #{env['rack.session']['user']} (<a href =\"?logout=true\">Logout</a>)"

	# Else, we want a way to authenticate ourselves
	else
		lgbox="<form method=\"post\" action=\"\"><input type=\"text\" id=\"login-text-user\" value=\"User\" name=\"wUser\"/><input type=\"password\" id=\"login-text-pass\" value=\"Pass\" name=\"wPass\"/><input type=\"submit\" id=\"login-submit\" value=\"\"/></form>"
	end

	if response.first then
		response.first.sub!('<div id=\'loginbox\'>','<div id=\'loginbox\'>' << lgbox)
	end

	# The ContentLength header, that might be set by server, is now most likely obsolete. We remove it.
	# It can be restored again using Rack::ContentLength
	# Note : maybe we should check whether sub! did something or not

	headers.delete('Content-Length')
	
	[status, headers, response]
  end
end
