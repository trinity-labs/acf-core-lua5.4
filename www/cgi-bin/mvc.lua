--[[ Basic MVC framework 
     Written for Alpine Configuration Framework (ACF)
     see www.alpinelinux.org for more information
     Copyright (C) 2007  Nathan Angelacos
     Licensed under the terms of GPL2
  ]]--
module(..., package.seeall)

require("posix")

mvc = {}

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
	local model_loaded = true
	local worker_loaded = true
	local c = {}
	c.worker = {}
	c.model = {}
	
	-- make defaults if the parent doesn't have them
	if self.conf == nil then
		c.conf = { appdir = "", confdir = "", 
				tempdir = "", appname = "" }
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
		c.worker = self:soft_require( modname .. "-controller") 
		if c.worker == nil then
			c.worker = {}
			worker_loaded = false
		end
		c.model = self:soft_require( modname ..  "-model" ) 
		if c.model == nil then
			c.model =  {}
			model_loaded = false
		end
	end

	-- The magic that makes all the metatables point in the correct 
	-- direction.  c.model -> c.worker -> parent -> parent.worker -> 
	-- grandparent -> grandparent -> worker (and so on)
	
	-- The model looks in worker for missing	
	setmetatable (c.model, c.model )
	c.model.__index = c.worker

	-- the worker looks in the parent table for missing 
	setmetatable (c.worker, c.worker)
	c.worker.__index = self
	
	-- the table looks in the worker for missing
	setmetatable (c, c)
	c.__index = c.worker
	
	-- ensure an "mvc" table exists, even if empty
	if (type(rawget(c.worker, "mvc")) ~= "table") then
		c.worker.mvc = {}
	end
	
	setmetatable (c.worker.mvc, c.worker.mvc)
	-- If creating a new parent container, then 
	-- we are the top of the chain.
	if (modname)  then
		c.worker.mvc.__index = self.worker.mvc
	else
		c.worker.mvc.__index = self.mvc
	end	
	
	-- run the worker on_load code
	if  type(rawget(c.worker.mvc, "on_load")) == "function" then
		c.worker.mvc.on_load(c, self) 
		c.worker.mvc.on_load = nil
	end

	-- save the new self on the SELF stack
	if not SELF then SELF = {} end
	SELF[#SELF + 1] = c

	return c, worker_loaded, model_loaded
end

destroy = function (self)
	if  type(rawget(self.worker.mvc, "on_unload")) == "function" then
		self.worker.mvc.on_unload(self)
		self.worker.mvc.on_unload = nil
	end

	-- remove the self from the SELF stack (should be at the end, but just in case)
	if SELF then
		for i,s in ipairs(SELF) do
			if s == self then
				table.remove(SELF, i)
				break
			end
		end
	end

	-- remove packages from package.loaded
	if self["_NAME"] then package.loaded[self["_NAME"]] = nil end
	if self.model and self.model["_NAME"] then package.loaded[self.model["_NAME"]] = nil end
end

-- This is a sample front controller/dispatch.   
dispatch = function (self, userprefix, userctlr, useraction) 
	local controller = nil
	local success, err = xpcall ( function () 

	if userprefix == nil then
		self.conf.prefix, self.conf.controller, self.conf.action =
			parse_path_info(ENV["PATH_INFO"])
	else
		self.conf.prefix = userprefix
		self.conf.controller = userctlr or ""
		self.conf.action = useraction or ""
	end

	-- If they didn't provide a controller, and a default was specified
	-- use it
	if self.conf.controller == "" and self.conf.default_controller then
		self.conf.controller = self.conf.default_controller
		self.conf.prefix = self.conf.default_prefix or "/"
	end

	local worker_loaded
	controller, worker_loaded = self:new(self.conf.prefix .. self.conf.controller)

	if not worker_loaded then
		self.conf.type = "dispatch"
		error(self.conf)
	end

	if controller.conf.action == "" then
		controller.conf.action = rawget(controller.worker, "default_action") or ""
	end

	local action = controller.conf.action

	-- Because of the inheritance, normally the 
	-- controller.worker.action will flow up, so that all children have
	-- actions of all parents.  We use rawget to make sure that only
	-- controller defined actions are used on dispatch
	-- If the action is missing, raise an error
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

	local viewfunc  = controller:view_resolver()

	-- we're done with the controller, destroy it
	controller:destroy()
	controller = nil
		
	viewfunc (viewtable)
	end, 
	self:soft_traceback(message)
	)

	if not success then
		local handler
		if controller then 
			handler = controller.worker or controller
			if handler then handler:exception_handler(err) end
			controller:destroy()
			controller = nil
		end
		if nil == handler then
			handler = self.worker or mvc
			handler:exception_handler(err)
		end
	end
end

-- Tries to see if name exists in the self.conf.appdir, and if so, it loads it.
-- otherwise, returns nil, but no error
soft_require = function (self, name )
	local filename, file
	for p in string.gmatch(self.conf.appdir, "[^,]+") do
		filename  = p .. name .. ".lua"
		file = io.open(filename)
		if file then
			file:close()
			local PATH=package.path
			-- FIXME - this should really try to open the lua file, 
			-- and if it doesnt exist silently fail.
			-- This version allows things from /usr/local/lua/5.1 to
			-- be loaded
			package.path = p .. "/?.lua;" .. package.path
			local t
			if posix.dirname(name) == "." then
				t = require(posix.basename(name))
			else
				t = require(posix.basename(posix.dirname(name)).."."..posix.basename(name))
			end
			package.path = PATH
			return t
		end
	end
	return nil
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
			self.conf.confdir = posix.dirname(filename) .. "/"
			self.conf.conffile = filename
                        for line in file:lines() do
                                key, value = string.match(line, "^%s*([^[=%s#]*)%s*=%s*(.*)")
                                if key then
                                        self.conf[key]  = value
                                end
			end
                	file:close()
			break
                end
        end

	if (#self.conf.confdir) then -- check for an appname-hooks.lua file
		self.conf.app_hooks = {}
		setmetatable (self.conf.app_hooks, {__index = _G})

		-- loadfile loads into the global environment
		-- so we set env 0, not env 1
		setfenv (0, self.conf.app_hooks)
		local f = loadfile(self.conf.confdir .. "/" .. appname.. "-hooks.lua")
		if (f) then f() end
		setfenv (0, _G)
		-- setmetatable (self.conf.app_hooks, {})
	end

end

-- parse a "URI" like string into a prefix, controller and action
-- return them (or blank strings)
parse_path_info = function( str )
	str = str or "" 
	local words = {}
	str = string.gsub(str, "/+$", "")
	for x=1,3 do
		words[#words+1] = string.match(str, "[^/]+$")
		str = string.gsub(str, "/+[^/]*$", "")
	end
	prefix = "/"..(words[#words] or "").."/"
	if prefix == "//" then prefix = "/" end
	controller = words[#words-1] or ""
	action = words[#words-2] or ""

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

-- create a Configuration Framework Entity (cfe)
-- returns a table with at least "value", "type", and "label"
cfe = function ( optiontable )
	optiontable = optiontable or {}
	me = { 	value="",
		type="text",
		label="" }
	for key,value in pairs(optiontable) do
		me[key] = value
	end
	return me
end
_G.cfe = cfe

logevent = function ( ... )
	os.execute ( "logger \"ACF: " .. (... or "") .. "\"" )
end
