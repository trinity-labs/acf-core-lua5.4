module(..., package.seeall)

require("posix")

local parent_exception_handler

mvc = {}
mvc.on_load = function (self, parent)
	-- Make sure we have some kind of sane defaults for libdir
	self.conf.libdir = self.conf.libdir or ( string.match(self.conf.appdir, "[^,]+/") .. "/lib/" )
	self.conf.script = ""
	self.conf.default_prefix = "/acf-util/"	
	self.conf.default_controller = "welcome"
	self.conf.viewtype = "serialized"

	parent_exception_handler = parent.exception_handler

	-- this sets the package path for us and our children
	for p in string.gmatch(self.conf.libdir, "[^,]+") do
		package.path=  p .. "?.lua;" .. package.path
	end

	self.session = {}
	local x=require("session")
end

mvc.pre_exec = function ()
end

mvc.post_exec = function ()
end

exception_handler = function (self, message )
	print(session.serialize("exception", message))
	parent_exception_handler(self, message)
end

redirect = function (self, str, result)
	return result
end

redirect_to_referrer = function(self, result)
	return result
end

-- syslog something
logevent = function ( ... )
	os.execute ( "logger \"" .. ... .. "\"" )
end
