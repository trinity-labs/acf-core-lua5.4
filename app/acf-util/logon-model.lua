-- Logon / Logoff model functions

module (..., package.seeall)

require ("session")
require ("html")

--varibles for time in case of logons,expired,lockouts
minutes_expired_events=30
minutes_count_events=30
limit_count_events=10

-- load an authenticator
-- FIXME: use an "always true" as default?

local auth 
if authenticator then
	auth = require ("authenticator-" .. conf.authenticator)
else
	auth = require ("authenticator-plaintext")
end

logon = function (self, id_user, password_user,sessdata )
local userid=cfe({ name="userid",type="text" })
local password=cfe({ name="password" ,type="password"})
local logon=cfe({ name="Logon", type="submit"})
local s = ""

local csess = session.check_session(conf.sessiondir, sessdata)
if csess ~= "an unknown user" then
session.unlink_session(conf.sessiondir, sessdata)
for a,b in pairs(sessiondata) do 
sessiondata[a] = nil
end
sessiondata.id = session.random_hash(512)
end

local counteven = session.count_events(conf.sessiondir, id_user, session.hash_ip_addr(ENV["REMOTE_ADDR"]), minutes_count_events)

if counteven > limit_count_events then
userid.errtxt="Information not recognized"
return (cfe {type="form",
	option={script=ENV["SCRIPT_NAME"],
	prefix=self.conf.prefix,
	controller=self.conf.controller,
	action="logon" },
	value={userid,password,logon},testme={counteven}
	})
end

session.expired_events(conf.sessiondir, minutes_expired_events)
	if id_user and password_user then
		if auth.authenticate (self, id_user, password_user)  then
			local t = auth.get_userinfo (self, id_user)
			sessiondata.id = session.random_hash(512)
			sessiondata.userinfo = t or {}
			self.conf.prefix="/acf-util/"
			self.conf.action="status"
			self.conf.type="redir"
			self.conf.controller="logon"
			error(self.conf)
		else
		userid.errtxt = "Information not recognized"
		session.record_event(conf.sessiondir, id_user, session.hash_ip_addr(ENV["REMOTE_ADDR"]))
	return (cfe {type="form",
		option={script=ENV["SCRIPT_NAME"],
		prefix=self.conf.prefix,
		controller=self.conf.controller,
		action="logon" },
		value={userid,password,logon},testme={counteven} 
		})
		end
	else
	return ( cfe{ type="form",
	option={script=ENV["SCRIPT_NAME"],
	prefix=self.conf.prefix,
	controller=self.conf.controller,
	action="logon" } ,
	value={userid,password,logon},testme={counteven}
	})
	end
end
		
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
	
	--this goes through and will return true or false if limit reached

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

