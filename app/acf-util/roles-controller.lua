-- Roles/Group functions

module (..., package.seeall)

read = function(self)
	--return( {read= self.model:read(clientdata.sessionid)})
	return ( { userid = self.sessiondata.userinfo.userid, roles = self.sessiondata.userinfo.roles, permissions = self.sessiondata.permissions } )
end

getlist = function(self)
	return( { contlist = self.model:getcont(self)})
end
