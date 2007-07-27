-- Logon / Logoff model functions

module (..., package.seeall)

local sess = require ("session")

local pvt = {}


-- return a sessionid if username / password is valid, false
-- /etc/acf/passwd should be lines of userid:passwd:user name:role1[,role2[,role3]]
pvt.logon = function (self, id, passwd )
	-- if we already have sessionid... then you are already logged in
	if self.session.id then
		return false
	end

	id = id or ""
	passwd = passwd or ""

	-- open our hokey password file,
	local f = io.open(self.conf.confdir .. "/passwd" )
	if f then
		m = f:read("*all") .. "\n"
		f:close()
	
		for l in string.gmatch(m, "(%C*)\n") do
			local userid, password, username, roles =
				string.match(l, "([^:]*):([^:]*):([^:]*):(.*)")
			if userid == id and password == passwd then
				self.session.id = sess.random_hash(512)
				self.session.name = username
				self.session.roles = roles
				break
			end
		end
	end
	if self.session.id then 
	        local x = require("session")
		 x.save_session(self.conf.sessiondir, self.session.id, self.session)
		x=nil
		return self.session.id 
	else
		return false
	end
end

-- invalidate the session, or return false if the session wasn't valid
pvt.logout = function (self, sessionid)

	sess.invalidate_session ( self.conf.sessiondir, sessionid)
	self.session = {}

end

-------------------------------------------------------------------------
-- Public Methods
-------------------------------------------------------------------------

logon = pvt.logon
logout = pvt.logout
