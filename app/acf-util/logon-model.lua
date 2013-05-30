-- Logon / Logoff model functions

module (..., package.seeall)

require ("session")
html = require ("acf.html")
fs = require ("acf.fs")
require ("roles")
require ("authenticator")

-- Logoff the user by deleting session data
logoff = function (sessiondir, sessiondata)
	-- Unlink / delete the current session
	local result = session.unlink_session(sessiondir, sessiondata.id)
	local success = (result ~= nil)
	-- Clear the current session data
	for a,b in pairs(sessiondata) do
		sessiondata[a] = nil
	end

	return cfe({ type="boolean", value=success, label="Logoff Success" })
end

-- Log on new user if possible and set up userinfo in session
-- if we fail, we leave the session alone (don't log off)
logon = function (self, userid, password, ip_addr, sessiondir, sessiondata)
	-- Check to see if we can log on this user id / ip addr
	local countevent = session.count_events(sessiondir, userid, session.hash_ip_addr(ip_addr), self.conf.lockouttime, self.conf.lockouteventlimit)
	if countevent then
		session.record_event(sessiondir, userid, session.hash_ip_addr(ip_addr))
	end

	if false == countevent and userid and password then
		if authenticator.authenticate (self, userid, password) then
			-- We have a successful logon, change sessiondata
			-- for some reason, can't call this function or it skips rest of logon
			-- logoff(sessiondir, sessiondata)
			---[[ so, do this instead
			session.unlink_session(sessiondir, sessiondata.id)
			-- Clear the current session data
			for a,b in pairs(sessiondata) do
				if a ~= "id" then sessiondata[a] = nil end
			end
			--]]
			sessiondata.id = session.random_hash(512)
			local t = authenticator.get_userinfo (self, userid)
			sessiondata.userinfo = {}
			for name,value in pairs(t) do
				sessiondata.userinfo[name] = value
			end
			return cfe({ type="boolean", value=true, label="Logon Success" })
		else
			-- We have a bad logon, log the event
			session.record_event(sessiondir, userid, session.hash_ip_addr(ip_addr))
		end
	end
	return cfe({ type="boolean", value=false, label="Logon Success" })
end

list_users = function(self)
	return cfe({ type="list", value=authenticator.list_users(self), label="Users" })
end
