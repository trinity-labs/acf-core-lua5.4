-- ACF Authenticator - does validation and loads sub-authenticator to read/write database
-- We store the login info in the passwd table, "" field.  It looks like
--	password:username:ROLE1[,ROLE2...]
module (..., package.seeall)

require("modelfunctions")
require("format")
require("md5")

-- This is the sub-authenticator
-- In the future, this will be set based upon configuration
-- This is a public variable to allow other controllers (ie tinydns) to do their own permissions
if APP and APP.conf and APP.conf.authenticator and APP.conf.authenticator ~= "" then
	auth = require(string.gsub(APP.conf.authenticator, "%.lua$", ""))
else
	auth = require("authenticator-plaintext")
end

-- Publicly define the pre-defined tables
usertable = "passwd"
roletable = "roles"

-- This will hold the auth structure from the database
local authstruct = {}
local complete = false

local parse_entry = function(id, entry)
	local a
	if id and id ~= "" and entry and entry ~= "" then
		local fields = {}
		for x in string.gmatch(entry or "", "([^:]*):?") do
			fields[#fields + 1] = x
		end
		a = {}
		a.userid = id
		a.password = fields[1] or ""
		a.username = fields[2] or ""
		a.roles = fields[3] or ""
		a.skin = fields[4] or ""
		a.home = fields[5] or ""
		authstruct[id] = a
	end
	return a
end

local load_database = function(self)
	if not complete then
		local authtable = auth.read_field(self, usertable, "") or {}
		authstruct = {}
		for i,value in ipairs(authtable) do
			parse_entry(value.id, value.entry)
		end
		complete = true
	end
end
	
local get_id = function(self, userid)
	if not authstruct[userid] then
		parse_entry(userid, auth.read_entry(self, usertable, "", userid))
	end
	return authstruct[userid]
end

--- public methods

-- This function returns true or false, and
-- if false:  the reason for failure
authenticate = function(self, userid, password)
	local errtxt

	if not userid or not password then
		errtxt = "Invalid parameter"
	else
		local id = get_id(self, userid)
		
		if not id then
			errtxt = "Userid not found"
		elseif id.password ~= md5.sumhexa(password) then
			errtxt = "Invalid password"
		end
	end

	return (errtxt == nil), errtxt
end

-- This function returns the username, roles, ...
get_userinfo = function(self, userid)
	local id = get_id(self, userid)
	if id then
		-- Make a copy so roles don't get changed in the authstruct
		local result = {}
		for n,v in pairs(id) do
			result[n]=v
		end
		local tmp = {}
		for x in string.gmatch(id.roles or "", "([^,]+),?") do
			tmp[#tmp + 1] = x
		end
		result.roles = tmp
		return result
	end
	return nil
end

write_userinfo = function(self, userinfo)
	if not userinfo or not userinfo.userid or userinfo.userid == "" then
		return false
	end
	id = get_id(self, userinfo.userid) or {}
	-- Username, password, roles, skin, home are allowed to not exist, just leave the same
	id.userid = userinfo.userid
	if userinfo.username then id.username = userinfo.username end
	if userinfo.password then id.password = md5.sumhexa(userinfo.password) end
	if userinfo.roles then id.roles = table.concat(userinfo.roles, ",") end
	if userinfo.skin then id.skin = userinfo.skin end
	if userinfo.home then id.home = userinfo.home end

	local success = auth.write_entry(self, usertable, "", id.userid, (id.password or "")..":"..(id.username or "")..":"..(id.roles or "")..":"..(id.skin or "")..":"..(id.home or ""))
	authstruct[userinfo.userid] = nil
	get_id(self, id.userid)

	if success and self.sessiondata and self.sessiondata.userinfo and self.sessiondata.userinfo.userid == id.userid then
		self.sessiondata.userinfo = {}
		for name,value in pairs(id) do
			self.sessiondata.userinfo[name] = value
		end
	end

	return success
end
	
list_users = function (self)
	load_database(self)
	local output = {}
	for k in pairs(authstruct) do
		table.insert(output,k)
	end
	return output
end

delete_user = function (self, userid)
	authstruct[userid] = nil	
	return auth.delete_entry(self, usertable, "", userid)
end
