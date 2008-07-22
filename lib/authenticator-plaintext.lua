--[[ ACF Logon/Logoff authenticator that uses plaintext files
	Copyright (c) 2007 Nathan Angelacos
	GPL2 license


The password file is in the format:

userid:password:username:role1[,role2...]:dnsfile1[,dnsfile2...]

]]--

module (..., package.seeall)

load_database = function(self)
	local row = {}

	-- open our password file
	local passwd_path = self.conf.confdir .. "/passwd"
	local f = io.open(passwd_path)
	if f then
		local m = (f:read("*all")  or "" ).. "\n"
		f:close()

		for l in string.gmatch(m, "([^\n]+)\n?") do
			local fields = {}
			for x in string.gmatch(l, "([^:]*):?") do
				fields[#fields + 1] = x
			end
			if fields[1] and fields[1] ~= "" then
				local a = {} 
				a.userid = fields[1] or ""
				a.password = fields[2] or ""
				a.username = fields[3] or ""
				a.roles = fields[4] or ""
				a.dnsfiles = fields[5] or ""
				table.insert (row, a)
			end
		end
		return row
	else	
		return nil
	end
end

write_entry = function(self, entry)
	delete_entry(self, entry.userid)

	-- Set path to passwordfile
	local passwd_path = self.conf.confdir .. "/passwd"
	-- Write the newline into the file
	fs.write_line_file(passwd_path, (entry.userid or "") .. ":" .. (entry.password or "") .. ":" .. (entry.username or "") .. ":" .. (entry.roles or "") .. ":" .. (entry.dnsfiles or "") )
	return true
end

delete_entry = function (self, userid)
	local result = false
	
	local passwd_path = self.conf.confdir .. "/passwd"
	local passwdfilecontent = fs.read_file_as_array(passwd_path)
	local output = {}
	for k,v in pairs(passwdfilecontent) do
		if not ( string.match(v, "^".. userid .. ":") ) and not string.match(v, "^%s*$") then
			table.insert(output, v)
		else
			result = true
		end
	end
	
	--Save the updated table
	if result == true then
		fs.write_file(passwd_path, table.concat(output,"\n"))
	end

	return result
end
