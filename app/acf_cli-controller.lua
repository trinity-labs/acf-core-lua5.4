module(..., package.seeall)

-- We use the parent exception handler in a last-case situation
local parent_exception_handler

mvc = {}
mvc.on_load = function (self, parent)
	
	-- Make sure we have some kind of sane defaults for libdir and sessiondir
	self.conf.libdir = self.conf.libdir or ( self.conf.appdir .. "/lib/" )
	self.conf.sessiondir = self.conf.sessiondir or "/tmp/"
	self.conf.appuri = ""
	self.conf.default_controller = "welcome"	

	parent_exception_handler = parent.exception_handler
	
	-- this sets the package path for us and our children
	package.path=  self.conf.libdir .. "?.lua;" .. package.path

	self.session = {}
	local x=require("session")
end

mvc.pre_exec = function ()
end

mvc.post_exec = function ()
end


view_resolver = function(self)
    return function (viewtable)
        print(viewtable)
    end
end

exception_handler = function (self, message )
    print(message)
end

-- create a Configuration Framework Entity (cfe) 
-- returns a table with at least "value", "type", "option" and "errtxt"
cfe = function ( optiontable )
	optiontable = optiontable or {}
	me = { 	value="",
		type="text",
		option="",
		errtxt="",
		name=""  }
	for key,value in pairs(optiontable) do
		me[key] = value
	end
	return me
end


-- syslog something
logit = function ( ... )
	os.execute ( "logger \"" .. ... .. "\"" )
end
