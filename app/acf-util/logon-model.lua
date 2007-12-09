-- Logon / Logoff model functions

module (..., package.seeall)

local sess = require ("session")

-- load an authenticator
-- FIXME: use an "always true" as default?

local auth 
if authenticator then
	auth = require ("authenticator-" .. conf.authenticator)
else
	auth = require ("authenticator-plaintext")
end


logon = function (self, id, password )
	-- logged on?
	--	record event and ignore the attempt
	-- too many attempts for this ip?
	--	record event and ignore the attempt
	-- too many attempts for this user?
	--	record event and ignore the attempt
	-- uname/passwd invalid?
	--	record event and ignore the attempt
	-- All ok?
	--	look up their role, issue new session
	return auth.authenticate (id, password)
end

logoff = function (self, sessionid)
	-- sessionid invalid?
	-- 	record event, ignore the attempt
	-- else
	-- 	unlink session
	--	issue new sessionid
end

