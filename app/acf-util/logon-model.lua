-- Logon / Logoff model functions

module (..., package.seeall)

require ("session")
require ("html")

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
	if auth.authenticate (self, id, password) then
		return auth.get_userinfo (self, id)
	else
		return nil
	end
end

logoff = function (self, sessdata)
	-- sessionid invalid?
	-- 	record event, ignore the attempt
	-- else
	-- 	unlink session
	--	issue new sessionid
	
	--made it so that we get a new sessionid then try to delete it
	--need to make the whole sessiondata table go bye bye
	delsess = session.unlink_session(conf.sessiondir, sessdata)
	if delsess == true then 
	logoff = "Successful"
	else
	logoff = "Incomplete or Unsuccessful logoff"
	end
	for a,b in pairs(sessiondata) do
	sessiondata[a] = nil
	end
	sessiondata.id = session.random_hash(512) 
	return ( cfe{ {value=logoff,name="logoff"},{value=sessiondata,name="sessiondata"} })
end

status = function(self, sessdata)
	sessid = sessdata
	checkme = session.check_session(self.conf.sessiondir,sessdata)	
	return ( cfe { checkme={value=checkme,name="checkme"}, sessid={value=sessid,name="sessid" } })	
end
