-- Logon / Logoff model functions

module (..., package.seeall)

require ("session")
require ("html")
require ("fs")
require ("roles")

--varibles for time in case of logons,expired,lockouts

-- load an authenticator
-- FIXME: use an "always true" as default?

local auth 
if authenticator then
	auth = require ("authenticator-" .. conf.authenticator)
else
	auth = require ("authenticator-plaintext")
end

-- Logoff the user by deleting session data
logoff = function (sessiondir, sessiondata)
	-- Unlink / delete the current session
	local result = session.unlink_session(sessiondir, sessiondata.id)
	local success = (result ~= nil)
	-- Clear the current session data
	for a,b in pairs(sessiondata) do
		sessiondata[a] = nil
	end

	return cfe({ type="boolean", value=success, name="Logoff Success" })
end

-- Log on new user if possible and set up userinfo in session
-- if we fail, we leave the session alone (don't log out)
logon = function (self, clientdata, ip_addr, sessiondir, sessiondata)
	-- Check to see if we can login this user id / ip addr
	local countevent = session.count_events(sessiondir, clientdata.userid, session.hash_ip_addr(ip_addr))
	if countevent then
		session.record_event(sessiondir, clientdata.userid, session.hash_ip_addr(ip_addr))
	end

	if false == countevent and clientdata.userid and clientdata.password then
		local password_user_md5 = fs.md5sum_string(clientdata.password)
		if auth.authenticate (self, clientdata.userid, password_user_md5) then
			-- We have a successful login, change sessiondata
			-- for some reason, can't call this function or it skips rest of logon
			-- logout(sessiondir, sessiondata)
			---[[ so, do this instead
			session.unlink_session(sessiondir, sessiondata.id)
			-- Clear the current session data
			for a,b in pairs(sessiondata) do
				if a ~= "id" then sessiondata[a] = nil end
			end
			--]]
			sessiondata.id = session.random_hash(512)
			local t = auth.get_userinfo (self, clientdata.userid)
			sessiondata.userinfo = t or {}
			return cfe({ type="boolean", value=true, name="Logon Success" })
		else
			-- We have a bad login, log the event
			session.record_event(sessiondir, clientdata.userid, session.hash_ip_addr(ip_addr))
		end
	end
	return cfe({ type="boolean", value=false, name="Logon Success" })
end

