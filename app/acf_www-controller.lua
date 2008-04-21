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

local function build_menus(self)
	m=require("menubuilder")
	roll = require ("roles")

	-- Build the permissions table
	local roles = {}
	if sessiondata.userinfo and sessiondata.userinfo.roles then
		roles = sessiondata.userinfo.roles
	end
	local permissions = roll.get_roles_perm(self.conf.appdir,roles)
	sessiondata.permissions = permissions
	
	--Build the menu
	local cats = m.get_menuitems(self.conf.appdir)
	-- now, loop through menu and remove actions without permission
	-- go in reverse so we can remove entries while looping
	for x = #cats,1,-1 do
		local cat = cats[x]
		for y = #cat.groups,1,-1 do
			local group = cat.groups[y]
			if nil == permissions[group.controller] then
				table.remove(cat.groups, y)
			else
				for z = #group.tabs,1,-1 do
					local tab = group.tabs[z]
					if nil == permissions[group.controller][tab.action] then
						table.remove(group.tabs, z)
					end
				end
				if 0 == #group.tabs then
					table.remove(cat.groups, y)
				end
			end
		end
		if 0 == #cat.groups then
			table.remove(cats, x)
		end
	end
	sessiondata.menu = {}
	sessiondata.menu.cats = cats

	-- Debug: Timestamp on menu creation
	sessiondata.menu.timestamp = {tab="Menu_created: " .. os.date(),action="Menu_created: " .. os.date(),}
end

mvc = {}
mvc.on_load = function (self, parent)
	-- open the log file
	self.conf.logfile = io.open ("/var/log/acf.log", "a+")

	-- Make sure we have some kind of sane defaults for libdir and sessiondir
	self.conf.libdir = self.conf.libdir or ( self.conf.appdir .. "/lib/" )
	self.conf.sessiondir = self.conf.sessiondir or "/tmp/"
	self.conf.appuri = "https://" .. ENV.HTTP_HOST .. ENV.SCRIPT_NAME
	self.conf.default_controller = "welcome"
	self.conf.default_action = "read"
	self.clientdata = FORM
	self.conf.clientip = ENV.REMOTE_ADDR

	parent_exception_handler = parent.exception_handler
	
	-- this sets the package path for us and our children
	package.path=  self.conf.libdir .. "?.lua;" .. package.path
	
	sessionlib=require ("session")

	-- before we look at sessions, remove old sessions and events
	-- this prevents us from giving a "session timeout" message, but I'm ok with that
	sessionlib.expired_events(self.conf.sessiondir)

	-- Load the session data
	self.sessiondata = nil
	self.sessiondata = {}
	if nil ~= self.clientdata.sessionid then
		logevent("Found session id = " .. self.clientdata.sessionid)
		-- Load existing session data
		local timestamp
		timestamp, self.sessiondata = 
			sessionlib.load_session(self.conf.sessiondir,
				self.clientdata.sessionid)
		if timestamp == nil then 
			-- invalid session id, report event and create new one
			sessionlib.record_event(self.conf.sessiondir,
				sessionlib.hash_ip_addr(self.conf.clientip))
			logevent("Didn't find session")
		else
			logevent("Found session")
			-- We read in a valid session, check if it's ok
			if sessionlib.count_events(self.conf.sessiondir,self.conf.userid or "", sessionlib.hash_ip_addr(self.conf.clientip)) then
				logevent("Bad session, erasing")
				-- Too many events on this id / ip, kill the session
				sessionlib.unlink_session(self.conf.sessiondir, self.clientdata.sessionid)
				self.sessiondata.id = nil
			end
		end
	end

	if nil == self.sessiondata.id then
		self.sessiondata = {}
		self.sessiondata.id = sessionlib.random_hash(512)
		logevent("New session = " .. self.sessiondata.id)
	end
	if nil == self.sessiondata.permissions or nil == self.sessiondata.menu then
		logevent("Build menus")
		build_menus(self)
	end
end

mvc.check_permission = function(self, controller, action)
	logevent("Trying " .. (controller or "nil") .. ":" .. (action or "nil"))
	if nil == self.sessiondata.permissions then return false end
	if controller then
		if nil == self.sessiondata.permissions[controller] then return false end
		if action and nil == self.sessiondata.permissions[controller][action] then return false end
	end
	return true
end

mvc.post_exec = function (self)
	sessionlib=require ("session")
	-- sessionlib.serialize("s", sessiondata))
	if sessiondata.id then
		sessionlib.save_session(conf.sessiondir, sessiondata)     
        end
	-- Close the logfile
	conf.logfile:close()
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
		local alpineversion  = self:new("alpine-baselayout/alpineversion")
		
		-- If the worker and model loaded correctly, then
		-- use the sub-controller
		local h
		if worker_loaded and model_loaded then
			h = m.worker.read(m)
		else
			h = {}
			h.hostname = { value = "unknown" }
		end
		
		local pageinfo =  { viewfile = viewname,
					controller = m.conf.controller,
					--          ^^^ see.. m.conf doesnt exist - but it works
					-- the inheritance means self.conf is used instead
					action = self.conf.action,
					hostname = h.hostname.value,
					-- alpineversion = alpineversion.worker.read(alpineversion),
					prefix = self.conf.prefix,
					script = self.conf.appuri, 
					skin = self.conf.skin or ""
					}

		return function (viewtable)
			local template = haserl.loadfile (template)
			return template ( pageinfo, viewtable, self.sessiondata )
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
	pcall(function()
		if sessiondata.id then logevent("Redirecting " .. sessiondata.id) end
		mvc.post_exec (self)
	end)	-- don't want exceptions from this
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
		name="", 
		label="" }
	for key,value in pairs(optiontable) do
		me[key] = value
	end
	return me
end

-- FIXME - need to think more about this..
logevent = function ( message )
	conf.logfile:write (string.format("%s: %s\n", os.date(), message)) 
end


