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
	if self.sessiondata.userinfo and self.sessiondata.userinfo.roles then
		roles = self.sessiondata.userinfo.roles
	end
	local permissions = roll.get_roles_perm(self.conf.appdir,roles)
	self.sessiondata.permissions = permissions
	
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
	self.sessiondata.menu = {}
	self.sessiondata.menu.cats = cats

	-- Debug: Timestamp on menu creation
	self.sessiondata.menu.timestamp = {tab="Menu_created: " .. os.date(),action="Menu_created: " .. os.date(),}
end

local check_permission = function(self, controller, action)
	logevent("Trying " .. (controller or "nil") .. ":" .. (action or "nil"))
	if nil == self.sessiondata.permissions then return false end
	if controller then
		if nil == self.sessiondata.permissions[controller] then return false end
		if action and nil == self.sessiondata.permissions[controller][action] then return false end
	end
	return true
end

-- look for a template
-- ctlr-action-view, then  ctlr-view, then action-view, then view
-- cannot be local function because of recursion
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
		return nil
	end
	prefix = dirname (prefix) 
	return find_template ( appdir, prefix, controller, action, viewtype )
end

-- look for a view
-- ctlr-action-view, then  ctlr-view
local find_view = function ( appdir, prefix, controller, action, viewtype )
	local names = { appdir .. prefix .. controller .. "-" ..
				action .. "-" .. viewtype .. ".lsp",
			appdir .. prefix .. controller .. "-" ..
				viewtype .. ".lsp" }
	local file
	-- search for view
	for i,filename in ipairs (names) do
		file = io.open(filename)
		if file then
			file:close()
			return filename
		end
	end
	return nil
end

-- This function is made available within the view to allow loading of components
local dispatch_component = function(str, clientdata, suppress_view)
	-- Before we call dispatch, we have to set up conf and clientdata like it was really called for this component
	self = APP
	local tempconf = self.conf
	self.conf = {}
	for x,y in pairs(tempconf) do
		self.conf[x] = y
	end
	self.conf.component = true
	self.conf.suppress_view = suppress_view
	local tempclientdata = self.clientdata
	self.clientdata = clientdata or {}
	self.clientdata.sessionid = tempclientdata.sessionid

	local prefix, controller, action = self.parse_path_info("/" .. str)
	if prefix == "/" then prefix = self.conf.prefix end
	if controller == "" then controller = self.conf.controller end
	local viewtable = self.dispatch(self, prefix, controller, action)

	-- Revert to the old conf and clientdata
	self.conf = nil
	if not (self.conf) then self.conf = tempconf end
	self.clientdata = nil
	if not (self.clientdata) then self.clientdata = tempclientdata end

	return viewtable
end

local create_helper_library = function ( self )
	local library = {}
--[[	-- If we have a separate library, here's how we could do it
	local library = require("library_name")
	for name,func in pairs(library) do
		if type(func) == "function" then
			library.name = function(...) return func(self, ...) end
		end
	end
--]]
	library.dispatch_component = dispatch_component
	return library
end

-- Our local view resolver called by our dispatch
local view_resolver = function(self)
	local template, viewname, viewlibrary
	local viewtype = self.conf.viewtype or "html"

	-- search for template
	if self.conf.component ~= true then
		template = find_template ( self.conf.appdir, self.conf.prefix,
			self.conf.controller, self.conf.action, viewtype )
	end
	
	-- search for view
	viewname = find_view ( self.conf.appdir, self.conf.prefix,
		self.conf.controller, self.conf.action, viewtype )

	local func = function() end
	if template then
		-- We have a template
		func = haserl.loadfile (template)
	elseif viewname then
		-- No template, but have a view
		func = haserl.loadfile (viewname)
	end
	
	-- create the view helper library
	viewlibrary = create_helper_library ( self )

	local pageinfo =  { viewfile = viewname,
				controller = self.conf.controller,
				action = self.conf.action,
				prefix = self.conf.prefix,
				appuri = self.conf.appuri,
				appname = self.conf.appname,
				skin = self.conf.skin or ""
				}

	return func, viewlibrary, pageinfo, self.sessiondata
end

mvc = {}
mvc.on_load = function (self, parent)
	-- open the log file
	self.conf.logfile = io.open ("/var/log/acf.log", "a+")

	--logevent("acf_www-controller mvc.on_load")

	-- Make sure we have some kind of sane defaults for libdir and sessiondir
	self.conf.libdir = self.conf.libdir or ( self.conf.appdir .. "/lib/" )
	self.conf.sessiondir = self.conf.sessiondir or "/tmp/"
	self.conf.appuri = "https://" .. ENV.HTTP_HOST .. ENV.SCRIPT_NAME
	self.conf.default_prefix = "/"
	self.conf.default_controller = "welcome"
	self.clientdata = FORM
	self.conf.clientip = ENV.REMOTE_ADDR

	-- FIXME this is because multi selects don't work in haserl
	for name,oldtable in pairs(self.clientdata) do
		if type(oldtable) == "table" then
			-- Assume it's a sparse array, and remove blanks
			local newtable={}
			for x=1,table.maxn(oldtable) do
				if oldtable[x] then
					newtable[#newtable + 1] = oldtable[x]
				end
			end
			self.clientdata[name] = newtable
		end
	end
	
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

mvc.on_unload = function (self)
	sessionlib=require ("session")
	if self.sessiondata.id then
		sessionlib.save_session(self.conf.sessiondir, self.sessiondata)
        end
	-- Close the logfile
	--logevent("acf_www-controller mvc.on_unload")
	self.conf.logfile:close()
end

-- Overload the MVC's exception handler with our own to handle redirection
exception_handler = function (self, message )
	local html = require ("html")
	if type(message) == "table" then
		if message.type == "redir" and self.conf.component == true then
			io.write ("Component cannot be found")
		elseif message.type == "redir" or message.type == "redir_to_referrer" then
			if self.sessiondata.id then logevent("Redirecting " .. self.sessiondata.id) end
			io.write ("Status: 302 Moved\n")
			if message.type == "redir" then
				io.write ("Location: " .. ENV["SCRIPT_NAME"] ..
				  	message.prefix .. message.controller ..
					"/" .. message.action .. 
					(message.extra or "" ) .. "\n")
			else
				io.write ("Location: " .. ENV.HTTP_REFERER .. "\n")
			end
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

-- Overload the MVC's dispatch function with our own
-- check permissions and redirect if not allowed to see
-- pass more parameters to the view
dispatch = function (self, userprefix, userctlr, useraction) 
	local controller = nil
	local viewtable
	local success, err = xpcall ( function () 

	if userprefix == nil then
		self.conf.prefix, self.conf.controller, self.conf.action =
			parse_path_info(ENV["PATH_INFO"])
	else
		self.conf.prefix = userprefix
		self.conf.controller = userctlr or ""
		self.conf.action = useraction or ""
	end

	-- Find the proper controller/action combo
	local origconf = {controller = self.conf.controller, action = self.conf.action}
	local action = ""
	local default_prefix = self.conf.default_prefix or "/"
	local default_controller = self.conf.default_controller or ""
	if "" == self.conf.controller then
		self.conf.prefix = default_prefix
		self.conf.controller = default_controller
		self.conf.action = ""
	end
	while "" ~= self.conf.controller do
		-- We now know the controller / action combo, check if we're allowed to do it
		local perm = check_permission(self, self.conf.controller)
		local worker_loaded = false

		if perm then
			controller, worker_loaded = self:new(self.conf.prefix .. self.conf.controller)
		end
		if worker_loaded then
			local default_action = rawget(controller.worker, "default_action") or ""
			action = self.conf.action
			if action == "" then action = default_action end
			while "" ~= action do
				local perm = check_permission(controller, self.conf.controller, action)
				-- Because of the inheritance, normally the 
				-- controller.worker.action will flow up, so that all children have
				-- actions of all parents.  We use rawget to make sure that only
				-- controller defined actions are used on dispatch
				if perm and (type(rawget(controller.worker, action)) == "function") then
					-- We have a valid and permissible controller / action
					self.conf.action = action
					break
				end
				if action ~= default_action then
					action = default_action
				else
					action = ""
				end
			end
			if "" ~= action then break end
		end
		if controller then
			controller:destroy()
			controller = nil
		end
		self.conf.action = ""
		if self.conf.controller ~= default_controller then
			self.conf.prefix = default_prefix
			self.conf.controller = default_controller
		else
			self.conf.controller = ""
		end
	end

	-- If the controller or action are missing, raise an error
	if nil == controller then
		origconf.type = "dispatch"
		error (origconf)
	end

	-- If we have different controller / action, redirect
	if self.conf.controller ~= origconf.controller or self.conf.action ~= origconf.action then
		redirect(self, self.conf.action) -- controller and prefix already in self.conf
	end

	-- run the (first found) pre_exec code, starting at the controller 
	-- and moving up the parents
	if  type(controller.worker.mvc.pre_exec) == "function" then
		controller.worker.mvc.pre_exec ( controller )
	end

	-- run the action		
	viewtable = controller.worker[action](controller)

	-- run the post_exec code
	if  type(controller.worker.mvc.post_exec) == "function" then
		controller.worker.mvc.post_exec ( controller )
	end

	if not self.conf.suppress_view then
		local viewfunc, p1, p2, p3 = view_resolver(self)
		viewfunc (viewtable, p1, p2, p3)
	end

	-- we're done with the controller, destroy it
	controller:destroy()
	controller = nil
		
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

	return viewtable
end

-- Cause a redirect to specified (or default) action
-- We use the self.conf table because it already has prefix,controller,etc
-- The actual redirection is defined in exception_handler above
redirect = function (self, str)
	local prefix, controller, action = self.parse_path_info("/" .. (str or ""))
	if prefix ~= "/" then self.conf.prefix = prefix end
	if controller ~= "" then self.conf.controller = controller end
	
	if "" == action then
		action = rawget(self.worker, "default_action") or ""
	end
	self.conf.action = action
	self.conf.type = "redir"
	error(self.conf)
end

redirect_to_referrer = function(self)
	error({type="redir_to_referrer"})
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

-- FIXME - need to think more about this..
logevent = function ( message )
	conf.logfile:write (string.format("%s: %s\n", os.date(), message or "")) 
end
