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
	local permissions = roll.get_roles_perm(self,roles)
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
	--logevent("Trying " .. (controller or "nil") .. ":" .. (action or "nil"))
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

local has_view = function(self)
	require("fs")
	local file = posix.stat(self.conf.appdir .. self.conf.prefix .. self.conf.controller .. "-" .. self.conf.action .. "-" .. (self.conf.viewtype or "html") .. ".lsp", "type")
	return file == "regular" or file == "link"
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
	self.conf.orig_action = self.conf.orig_action or self.conf.prefix .. self.conf.controller .. "/" .. self.conf.action
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
				script = self.conf.script,
				appname = self.conf.appname,
				skindir = self.conf.skindir or "",
				skin = self.conf.skin or "",
				orig_action = self.conf.orig_action or self.conf.prefix .. self.conf.controller .. "/" .. self.conf.action
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
	self.conf.script = ENV.SCRIPT_NAME
	self.conf.default_prefix = "/"
	self.conf.default_controller = self.conf.default_controller or "welcome"
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
		--logevent("Found session id = " .. self.clientdata.sessionid)
		-- Load existing session data
		local timestamp
		timestamp, self.sessiondata = 
			sessionlib.load_session(self.conf.sessiondir,
				self.clientdata.sessionid)
		if timestamp == nil then 
			-- invalid session id, report event and create new one
			sessionlib.record_event(self.conf.sessiondir, nil,
				sessionlib.hash_ip_addr(self.conf.clientip))
			--logevent("Didn't find session")
		else
			--logevent("Found session")
			-- We read in a valid session, check if it's ok
			if sessionlib.count_events(self.conf.sessiondir,self.conf.userid or "", sessionlib.hash_ip_addr(self.conf.clientip)) then
				--logevent("Bad session, erasing")
				-- Too many events on this id / ip, kill the session
				sessionlib.unlink_session(self.conf.sessiondir, self.clientdata.sessionid)
				self.sessiondata.id = nil
			end
		end
	end

	if nil == self.sessiondata.id then
		self.sessiondata = {}
		self.sessiondata.id = sessionlib.random_hash(512)
		--logevent("New session = " .. self.sessiondata.id)
	end
	if nil == self.sessiondata.permissions or nil == self.sessiondata.menu then
		--logevent("Build menus")
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
	local viewtable
	if type(message) == "table" then
		if self.conf.component == true then
			io.write ("Component cannot be found")
		elseif message.type == "dispatch" and self.sessiondata.userinfo and self.sessiondata.userinfo.userid then
			viewtable = message
			self.conf.prefix = "/"
			self.conf.controller = "dispatcherror"
			self.conf.action = ""
		elseif message.type == "redir" or message.type == "redir_to_referrer" or message.type == "dispatch" then
			--if self.sessiondata.id then logevent("Redirecting " .. self.sessiondata.id) end
			io.write ("Status: 302 Moved\n")
			if message.type == "redir" then
				io.write ("Location: " .. ENV["SCRIPT_NAME"] ..
				  	message.prefix .. message.controller ..
					"/" .. message.action .. 
					(message.extra or "" ) .. "\n")
			elseif message.type == "dispatch" then
				io.write ("Location: " .. ENV["SCRIPT_NAME"] .. "/acf-util/logon/logon?redir="..message.prefix..message.controller.."/"..message.action.."\n")
			else
				io.write ("Location: " .. ENV.HTTP_REFERER .. "\n")
			end
			if self.sessiondata.id then
				io.write (html.cookie.set("sessionid", self.sessiondata.id))
			else
				io.write (html.cookie.unset("sessionid"))
			end
			io.write ( "Content-Type: text/html\n\n" )
		else
			parent_exception_handler(self, message)
		end
	else
		viewtable = {message = message}
		self.conf.prefix = "/"
		self.conf.controller = "exception"
		self.conf.action = ""
	end

	if viewtable then
		if not self.conf.suppress_view then
			local success, err = xpcall ( function () 
				local viewfunc, p1, p2, p3 = view_resolver(self)
				viewfunc (viewtable, p1, p2, p3)
			end, 
			self:soft_traceback()
			)

			if not success then
				parent_exception_handler(self, err)
			end
		end
	end
end

-- Overload the MVC's dispatch function with our own
-- check permissions and redirect if not allowed to see
-- pass more parameters to the view
-- allow display of views without actions
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
	local origconf = {}
	for name,value in pairs(self.conf) do origconf[name]=value end
	if "" == self.conf.controller then
		self.conf.prefix = self.conf.default_prefix or "/"
		self.conf.controller = self.conf.default_controller or ""
		self.conf.action = ""
	end
	if "" ~= self.conf.controller then
		-- We now know the controller / action combo, check if we're allowed to do it
		local perm = check_permission(self, self.conf.controller)
		local worker_loaded = false

		if perm then
			controller, worker_loaded = self:new(self.conf.prefix .. self.conf.controller)
		end
		if worker_loaded then
			local default_action = rawget(controller.worker, "default_action") or ""
			if self.conf.action == "" then self.conf.action = default_action end
			if "" ~= self.conf.action then
				local perm = check_permission(controller, self.conf.controller, self.conf.action)
				-- Because of the inheritance, normally the 
				-- controller.worker.action will flow up, so that all children have
				-- actions of all parents.  We use rawget to make sure that only
				-- controller defined actions are used on dispatch
				if (not perm) or (type(rawget(controller.worker, self.conf.action)) ~= "function") then
					controller:destroy()
					controller = nil
				end
			end
		elseif controller then
			controller:destroy()
			controller = nil
		end
	end

	-- If we have different controller / action, redirect
	if self.conf.controller ~= origconf.controller or self.conf.action ~= origconf.action then
		redirect(self, self.conf.action) -- controller and prefix already in self.conf
	end

	-- If the controller or action are missing, display an error view
	if nil == controller then
		-- If we have a view w/o an action, just display the view (passing in the clientdata)
		if (not self.conf.suppress_view) and has_view(self) and check_permission(self, self.conf.controller, self.conf.action) then
			viewtable = self.clientdata
		else
			origconf.type = "dispatch"
			error (origconf)
		end
	end

	if controller then
		-- run the (first found) pre_exec code, starting at the controller 
		-- and moving up the parents
		if  type(controller.worker.mvc.pre_exec) == "function" then
			controller.worker.mvc.pre_exec ( controller )
		end

		-- run the action		
		viewtable = controller.worker[self.conf.action](controller)

		-- run the post_exec code
		if  type(controller.worker.mvc.post_exec) == "function" then
			controller.worker.mvc.post_exec ( controller )
		end

		-- we're done with the controller, destroy it
		controller:destroy()
		controller = nil
	end

	if not self.conf.suppress_view then
		local viewfunc, p1, p2, p3 = view_resolver(self)
		viewfunc (viewtable, p1, p2, p3)
	end
		
	end, 
	self:soft_traceback(message)
	)

	if not success then
		if controller then 
			controller:exception_handler(err)
			controller:destroy()
			controller = nil
		else
			self:exception_handler(err)
		end
	end

	return viewtable
end

-- Cause a redirect to specified (or default) action
-- We use the self.conf table because it already has prefix,controller,etc
-- The actual redirection is defined in exception_handler above
redirect = function (self, str, result)
	if result then
		self.sessiondata[self.conf.action.."result"] = result
	end
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

-- If we've done something, cause a redirect to the referring page (assuming it's different)
-- Also handles retrieving the result of a previously redirected action
redirect_to_referrer = function(self, result)
	if result and not self.conf.component then
		-- If we have a result, then we did something, so we might have to redirect
		if not ENV.HTTP_REFERER then
			-- If no referrer, we have a problem.  Can't let it go through, because action
			-- might not have view.  So redirect to default action for this controller.
			self:redirect()
		else
			local prefix, controller, action = self.parse_path_info(ENV.HTTP_REFERER:gsub("%?.*", ""))
			if controller ~= self.conf.controller or action ~= self.conf.action then
				self.sessiondata[self.conf.action.."result"] = result
				error({type="redir_to_referrer"})
			end
		end
	elseif self.sessiondata[self.conf.action.."result"] then
		-- If we don't have a result, but there's a result in the session data,
		-- then we're a component redirected as above.  Return the last result.
		result = self.sessiondata[self.conf.action.."result"]
		self.sessiondata[self.conf.action.."result"] = nil
	end
	return result
end

-- FIXME - need to think more about this..
logevent = function ( message )
	conf.logfile:write (string.format("%s: %s\n", os.date(), message or "")) 
end
