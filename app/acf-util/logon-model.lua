-- Logon / Logoff model functions

module (..., package.seeall)

require ("session")
require ("html")
require ("fs")
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
-- if we fail, we leave the session alone (don't log out)
logon = function (self, userid, password, ip_addr, sessiondir, sessiondata)
	-- Check to see if we can login this user id / ip addr
	local countevent = session.count_events(sessiondir, userid, session.hash_ip_addr(ip_addr))
	if countevent then
		session.record_event(sessiondir, userid, session.hash_ip_addr(ip_addr))
	end

	if false == countevent and userid and password then
		if authenticator.authenticate (self, userid, password) then
			-- We have a successful login, change sessiondata
			-- for some reason, can't call this function or it skips rest of logon
			-- logout(sessiondir, sessiondata)
			---[[ so, do this instead
			session.unlink_session(sessiondir, sessiondata.id)
			-- Clear the current session data
			for a,b in pairs(sessiondata) do
				if a ~= "id" and a ~= "logonredirect" then sessiondata[a] = nil end
			end
			--]]
			sessiondata.id = session.random_hash(512)
			local t = authenticator.get_userinfo (self, userid)
			sessiondata.userinfo = {}
			for name,value in pairs(t.value) do
				sessiondata.userinfo[name] = value.value
			end
			return cfe({ type="boolean", value=true, label="Logon Success" })
		else
			-- We have a bad login, log the event
			session.record_event(sessiondir, userid, session.hash_ip_addr(ip_addr))
		end
	end
	return cfe({ type="boolean", value=false, label="Logon Success" })
end

list_users = function(self)
	return cfe({ type="list", value=authenticator.list_users(self), label="Users" })
end
