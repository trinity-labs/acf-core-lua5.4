--[[ Basic MVC framework 
     Written for Alpine Configuration Framework (ACF) -- see www.alpinelinux.org
     Copyright (C) 2007  Nathan Angelacos
     Licensed under the terms of GPL2
  ]]--
module(..., package.seeall)

-- the constructor
--[[ Builds a new MVC object.  If "module" is given, then tries to load
	self.conf.appdir ..  module "-controller.lua" in c.worker and
	self.conf.appdir ..  module "-model.lua" in c.model 

	The returned  .conf table is guaranteed to have the following
	appdir - where the application lives
	confdir - where the configuration file is
	sessiondir - where session data and other temporary stuff goes
	appname - the name of the application
	]]

new = function (self, modname)
	local c = {}
	c.worker = {}
	c.model = {}
	
	-- make defaults if the parent doesn't have them
	if self.conf == nil then
		c.conf = { appdir = "", confdir = "", tempdir = "", appname = "" }
	end

	-- If no clientdata, then clientdata is a null table
	if self.clientdata == nil then 
		c.clientdata = {} 
		end

	-- If we don't have an application name, use the modname
	if (self.conf == nil ) or (self.conf.appname == nil) then
		c.conf.appname = modname
	end

	-- load the module code here
	if (modname) then
		c.worker = self:soft_require( modname .. "-controller") or {}
		c.model = self:soft_require( modname ..  "-model" ) or {}
	end

	-- The magic that makes all the metatables point in the correct 
	-- direction.  c.model -> c.worker -> parent -> parent.worker -> 
	-- grandparent -> grandparent -> worker (and so on)
	
	-- The model looks in worker for missing	
	setmetatable (c.model, c.model )
	c.model.__index = c.worker

	-- the worker looks in the main table for missing 
	setmetatable (c.worker, c.worker)
	c.worker.__index = c
	
	-- the table looks in the parent worker for missing
	setmetatable (c, c)
	
	-- ensure an "mvc" table exists, even if empty
	if (type(rawget(c.worker, "mvc")) ~= "table") then
		c.worker.mvc = {}
	end
	
	setmetatable (c.worker.mvc, c.worker.mvc)
	-- If creating a new parent container, then 
	-- we are the top of the chain.
	if (modname)  then
		c.__index = self.worker
		c.worker.mvc.__index = self.worker.mvc
	else
		c.__index = self
		c.worker.mvc.__index = self.mvc
	end	
	
	
	-- run the worker on_load code
	if  type(rawget(c.worker.mvc, "on_load")) == "function" then
		c.worker.mvc.on_load(c, self) 
		c.worker.mvc.on_load = nil
	end

	return c
end

-- This is a sample front controller/dispatch.   
dispatch = function (self, prefix, controller, action) 
	local controller
	local success, err = xpcall ( function () 

	if prefix == nil then
		self.conf.prefix, self.conf.controller, self.conf.action =
			parse_path_info(ENV["PATH_INFO"])
	else
		self.conf.prefix = prefix
		self.conf.controller = controller or ""
		self.conf.action = action or ""
	end
	
	-- If they didn't provide a controller, and a default was specified
	-- use it
	if self.conf.controller == "" and self.conf.default_controller then
		self.conf.controller = self.conf.default_controller
	end

	controller = self:new(self.conf.prefix .. self.conf.controller)

	local action = controller.conf.action

	-- Because of the inheritance, normally the 
	-- controller.worker.action will flow up, so that all children have
	-- actions of all parents.  We sue rawget to make sure that only
	-- controller defined actions are used on dispatch
	-- If the controller or action are missing, raise an error
	if ( type(rawget(controller.worker, action)) ~= "function") then
			self.conf.type = "dispatch"
			error (self.conf)
	end

	-- run the (first found) pre_exec code, starting at the controller 
	-- and moving up the parents
	if  type(controller.worker.mvc.pre_exec) == "function" then
		controller.worker.mvc.pre_exec ( controller )
	end

 	-- run the action		
	local viewtable = controller.worker[action](controller)


	-- run the post_exec code
	if  type(controller.worker.mvc.post_exec) == "function" then
		controller.worker.mvc.post_exec ( controller )
	end
	

	local viewfunc  = controller:view_resolver(viewtable)

	viewfunc (viewtable)
	end, 
	self:soft_traceback(message)
	)

	if not success then
		local handler
		if controller then 
			handler = controller.worker or controller
		end
		handler = handler or self.worker or mvc
		handler:exception_handler(err)
	end
end


-- Tries to see if name exists in the self.conf.appdir, and if so, it loads it.
-- otherwise, returns nil, but no error
soft_require = function (self, name )
	local filename, file
	filename  = self.conf.appdir .. name .. ".lua"
	file = io.open(filename)
	if file then
		file:close()
		local PATH=package.path
		-- FIXME - this should really try to open the lua file, 
		-- and if it doesnt exist silently fail.
		-- This version allows things from /usr/local/lua/5.1 to
		-- be loaded
		package.path = self.conf.appdir .. "?" .. ".lua;" .. package.path
		local t = require(name)
		package.path = PATH
		return t
	end
	return nil
end

--  see man basename.1 
basename = function (string, suffix)
	string = string or ""
	local basename = string.gsub (string, "[^/]*/", "")
	if suffix then 
		basename = string.gsub ( basename, suffix, "" )
	end
	return basename 
end

-- see man dirname.1
dirname = function ( string)
	string = string or ""
	-- strip trailing / first
	string = string.gsub (string, "/$", "")
	local basename = basename ( string)
	string = string.sub(string, 1, #string - #basename - 1)
	return(string)	
end 

-- look in various places for a config file, and store it in self.conf
read_config = function( self, appname )
	appname = appname or self.conf.appname
	self.conf.appname = self.conf.appname or appname
	
	local confs = { (ENV["HOME"] or ENV["PWD"] or "") .. "/." ..
				appname .. "/" .. appname .. ".conf",
			( ENV["HOME"] or ENV["PWD"] or "") .. "/" .. 
				appname .. ".conf",
			ENV["ROOT"] or "" .. "/etc/" .. appname .. "/" .. 
				appname .. ".conf",
			ENV["ROOT"] or "" .. "/etc/" .. appname .. ".conf"
	}
	for i, filename in ipairs (confs) do
                local file = io.open (filename)
                if (file) then
			self.conf.confdir = dirname(filename) .. "/"
                        for line in file:lines() do
                                key, value = string.match(line, "([^[=]*)=[ \t]*(.*)")
                                if key then -- ugly way of finding blank spots between key and =
                                        repeat
                                                local space = string.find ( key, "%s", -1)
                                                if space then key=string.sub(key,1,space-1) end
                                        until space == nil
                                        self.conf[key]  = value
                                end
			end
                	file:close()
			break
                end
        end
end

-- parse a "URI" like string into a prefix, controller and action
-- return them (or blank strings)
parse_path_info = function( str )
	str = str or "" 
	-- If it ends in a /, then add another to force
	-- a blank action (the user gave a controller without action)
	if  string.match (str, "[^/]/$" ) then 
		str = str .. "/"
	end
	local action = basename(str)
	local temp = dirname(str)
	local controller = basename(temp)
	local prefix = dirname(temp) .. "/"
	return prefix, controller, action
end

-- The view resolver of last resort.
view_resolver = function(self)
	return function()
		if ENV["REQUEST_METHOD"] then 
			io.write ("Content-type: text/plain\n\n")
		end
		io.write ("Your controller and application did not specify a view resolver.\n")
		io.write ("The MVC framework has no view available. sorry.\n")
	return
	end
end

-- Generates a debug.traceback if called with no arguments
soft_traceback = function (self, message )
	if message then
		return message
	else
		return debug.traceback
	end
end

-- The exception hander of last resort
exception_handler = function (self, message )
	if ENV["REQUEST_METHOD"] then
		print ("Content-Type: text/plain\n\n")
	end
	print ("The following unhandled application error occured:\n\n")

	if (type(message) == "table" ) then
		if (message.type == "dispatch") then
		print ('controller: "' .. message.controller .. '" does not have a "' .. 
			message.action .. '" action.')
		else
		print ("An error of type: '" .. (tostring(message.type) or "nil") .. "' was raised." )
		end
	else
		print (tostring(message))
	end
end
