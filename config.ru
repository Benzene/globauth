require_relative 'Globauth-rack'

use Rack::Lint
use Rack::ContentLength
use Rack::ShowExceptions

use Rack::Session::Pool, :domain => 'marchroutka.leukensis.org', :expire_after => 60 * 60 * 24 * 30, :secure => true
use Globauth

app = lambda { |env| 
	if env['rack.session']['uid'] then
		greet_msg = "Hello #{env['rack.session']['user']} (#{env['rack.session']['uid']}) (#{env['rack.session']['groups']}) <br />"
	else
		greet_msg = ''
	end
	[200, { 'Content-Type' => 'text/html' }, ['Hello World!<br />
		' << greet_msg << '
		<form method="post" action=""><input type="text" name="wUser"/><input type="text" name="wPass"/><input type="submit" /></form>'] ]}
run app

