-- Roles/Group functions

module (..., package.seeall)

read = function(self)
	return ( { userid = self.sessiondata.userinfo.userid, roles = self.sessiondata.userinfo.roles, permissions = self.sessiondata.permissions } )
end

getlist = function(self)
	return( { contlist = self.model:getcont(self)})
end
