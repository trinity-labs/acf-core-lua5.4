--[[ Code for the Alpine Configuration WEB framework 
      see http://wiki.alpinelinux.org
      Copyright (C) 2007  Nathan Angelacos
      Licensed under the terms of GPL2
   ]]--
-- Required global libraries

module(..., package.seeall)

-- This is not in the global namespace, but future
-- require statements shouldn't need to go to the disk lib
require "posix"


-- We use the parent exception handler in a last-case situation
local parent_exception_handler

mvc = {}
mvc.on_load = function (self, parent)
	
	-- Make sure we have some kind of sane defaults for libdir and sessiondir
	self.conf.libdir = self.conf.libdir or ( self.conf.appdir .. "/lib/" )
	self.conf.sessiondir = self.conf.sessiondir or "/tmp/"
	self.conf.appuri = "http://" .. ENV.HTTP_HOST .. ENV.SCRIPT_NAME
	self.conf.default_controller = "welcome"	
	self.clientdata = FORM
	self.conf.clientip = ENV.REMOTE_ADDR

	parent_exception_handler = parent.exception_handler
	
	-- this sets the package path for us and our children
	package.path=  self.conf.libdir .. "?.lua;" .. package.path
	
	sessionlib=require ("session")
	
	self.sessiondata = {}
	local tempid = ""
	if self.clientdata.sessionid == nil then
		self.sessiondata.id  = sessionlib.random_hash(512) 
		tempid = self.sessiondata.id
	else
		local timestamp
		tempid = self.clientdata.sessionid
		timestamp, self.sessiondata = 
			sessionlib.load_session(self.conf.sessiondir,
				self.clientdata.sessionid)
		if timestamp == nil then 
			self.sessiondata.id = tempid
			sessionlib.record_event(self.conf.sessiondir,
				sessionlib.hash_ip_addr(self.conf.clientip))
		else
			--[[
			FIXME --- need to write this function
			if too many bad events for this ip invaidate the session
		
			if (timestamp is > 10 minutes old)	
			sessionlib.unlink.session (self.conf.sessiondir,
				self.sessiondata.id)
			self.sessiondata = {}
			self.sessiondata.id = sessionlib.random_hash(512)
			generate flash message "Inactivity logout"
			end
			]]--
		end
	end
end


mvc.post_exec = function (self)
	if sessiondata.id then
		sessionlib.save_session(conf.sessiondir, 
        			sessiondata.id, sessiondata)     
        end
end


-- look for a template
-- ctlr-action-view, then  ctlr-view, then action-view, then view

find_template = function ( appdir, prefix, controller, action, viewtype )
	local targets = {
			appdir .. prefix .. "template-" .. controller .. "-" .. 
				action .. "-" .. viewtype .. ".lsp",
			appdir .. prefix .. "template-" .. controller .. "-" .. 
				viewtype .. ".lsp",
			appdir .. prefix .. "template-" .. action .. "-" ..
				viewtype .. ".lsp",
			appdir .. prefix .. "template-" .. viewtype .. ".lsp"
			}
	local file
	for k,v in pairs(targets) do
		file = io.open (v)
		if file then 
			io.close (file)
			return v
		end
	end
	-- not found, so try one level higher
	if prefix == "" then -- already at the top level - fail
		return false
	end
	prefix = dirname (prefix) 
	return find_template ( appdir, prefix, controller, action, viewtype )
end



-- Overload the MVC's view resolver with our own

view_resolver = function(self)
	local file
	local viewname
	local viewtype = self.conf.viewtype or "html"
	local names = { self.conf.appdir .. self.conf.prefix .. self.conf.controller ..
				"-" .. self.conf.action .. "-" .. viewtype .. ".lsp",
			self.conf.appdir .. self.conf.prefix .. self.conf.controller ..
				"-" .. viewtype .. ".lsp" }


	-- search for template
	local template = find_template ( self.conf.appdir, self.conf.prefix,
		self.conf.controller, self.conf.action, "html") 
	
	-- search for view
	for i,filename in ipairs (names) do
		file = io.open(filename)
		if file then
			file:close()
			viewname = filename
			break
		end
	end

	-- We have a template
	if template then
		-- ***************************************************
		-- This is how to call another controller (APP or self
		-- can be used... m will contain worker and model,
		-- with conf, and other "missing" parts pointing back
		-- to APP or self
		-- ***************************************************
		local m,worker_loaded,model_loaded  = self:new("alpine-baselayout/hostname")
		
		-- FIXME - this is ugly, but it puts the hostname the expected
		-- format if the controller doesn't load correctly 
		local h = {}
		
		-- If the worker and model loaded correctly, then
		-- use the sub-controller
		if worker_loaded and model_loaded then
			h = m.worker.read(m)
		else
			h.hostname = { value = "unknown" }
		end
		
		local pageinfo =  { viewfile = viewname,
					controller = m.conf.controller,
					--          ^^^ see.. m.conf doesnt exist - but it works
					-- the inheritance means self.conf is used instead
					action = self.conf.action,
					hostname = h.hostname.value,
					prefix = self.conf.prefix,
					script = self.conf.appuri, 
					skin = self.conf.skin or ""
					}

		-- Build the menu table
		m=require("menubuilder")
		local menu = m.get_menuitems(self.conf.appdir)

		-- A quick hack
		submenu = {}
		for k,v in pairs ( self.worker ) do
			if type ( self.worker[k] ) == "function" then
				table.insert (submenu, k)	
			end
		end

		return function (viewtable)
			local template = haserl.loadfile (template)
			return template ( pageinfo, menu, submenu, viewtable, self.sessiondata )
		end
	end

	-- No template, but have a view
	if viewname then
		return haserl.loadfile (viewname)
	else
		return function() end 
	end
end

exception_handler = function (self, message )
	local html = require ("html")
	if type(message) == "table" then
		if message.type == "redir" then
			io.write ("Status: 302 Moved\n")
			io.write ("Location: " .. ENV["SCRIPT_NAME"] ..
				  	message.prefix .. message.controller ..
					"/" .. message.action .. 
					(message.extra or "" ) .. "\n")
				if self.sessiondata.id then
					io.write (html.cookie.set("sessionid", self.sessiondata.id))
				else
					io.write (html.cookie.unset("sessionid"))
				end
			io.write ( "Content-Type: text/html\n\n" )
		elseif message.type == "dispatch" then
			parent_exception_handler(self, message)
		end
		else
		parent_exception_handler( self, message)
	end
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
