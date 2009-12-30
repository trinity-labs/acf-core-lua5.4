module(..., package.seeall)

require("authenticator")

function create_user(self, userdata)
	return authenticator.new_settings(self, userdata)
end

function read_user(self, user)
	local retval = authenticator.get_userinfo(self, user)
	if not user then
		local userlist = authenticator.list_users(self)
		if #userlist == 0 then
			-- There are no users yet, suggest some values
			retval.value.userid.value = "root"
			retval.value.username.value = "Admin account"
			retval.value.roles.value = {"ADMIN"}
		end
	end
	return retval
end

function update_user(self, userdata)
	return authenticator.change_settings(self, userdata)
end

function get_users(self)
	--List all users and their userinfo
	local users = {}
	local userlist = authenticator.list_users(self)
	
	for x,user in pairs(userlist) do
		users[user] = read_user(self, user)
		users[user].value.password = nil
		users[user].value.password_confirm = nil
	end

	return cfe({ type="group", value=users, label="User Configs" })
end

function delete_user(self, userid)
	return authenticator.delete_user(self, userid)
end
