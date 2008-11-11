--[[ ACF Logon/Logoff authenticator that uses plaintext files
	Copyright (c) 2007 Nathan Angelacos
	GPL2 license

Rather than come up with a way to name fields in the plaintext files, we
create a different file for each field.

]]--

module (..., package.seeall)

list_fields = function(self, tabl)
	if not self or not tabl or tabl == "" then
		return {}
	end

	local fields = {}
	for file in fs.find(".*"..tabl, self.conf.confdir) do
		local field = string.match(file, "([^/]*)"..tabl.."$") or ""
		if fs.is_file(file) and field ~= "" then
			fields[#fields + 1] = field
		end
	end
	return fields
end

read_field = function(self, tabl, field)
	if not self or not tabl or tabl == "" or not field then
		return nil
	end

	local row = {}
	-- open our password file
	local passwd_path = self.conf.confdir .. field .. tabl
	local f = io.open(passwd_path)
	if f then
		local m = (f:read("*all")  or "" ).. "\n"
		f:close()

		for l in string.gmatch(m, "([^\n]+)\n?") do
			local a = {}
			a.id, a.entry = string.match(l, "^([^:=]*)[:=](.*)")
			table.insert(row, a)
		end
		return row
	else	
		return nil
	end
end

delete_field = function(self, tabl, field)
	if not self or not tabl or tabl == "" or not field then
		return false
	end
	local passwd_path = self.conf.confdir .. field .. tabl
	os.remove(passwd_path)
	return true
end

write_entry = function(self, tabl, field, id, entry)
	if not self or not tabl or tabl == "" or not field or not id or not entry then
		return false
	end

	-- Set path to passwordfile
	local passwd_path = self.conf.confdir .. field .. tabl
	-- Write the newline into the file
	if fs.is_file(passwd_path) == false then fs.create_file(passwd_path) end
	if fs.is_file(passwd_path) == false then return false end
	local passwdfilecontent = fs.read_file_as_array(passwd_path) or {}
	local output = {id .. ":" .. entry}
	for k,v in pairs(passwdfilecontent) do
		if not ( string.match(v, "^".. id .. "[:=]") ) and not string.match(v, "^%s*$") then
			table.insert(output, v)
		end
	end
	fs.write_file(passwd_path, table.concat(output, "\n"))
	return true
end

read_entry = function(self, tabl, field, id)
	if not self or not tabl or tabl == "" or not field or not id then
		return nil
	end
	-- Set path to passwordfile
	local passwd_path = self.conf.confdir .. field .. tabl
	local passwdfilecontent = fs.read_file_as_array(passwd_path) or {}
	local entry
	for k,v in pairs(passwdfilecontent) do
		if string.match(v, "^".. id .. "[:=]") then
			return string.match(v, "^"..id.."[:=](.*)")
		end
	end
	return nil
end

delete_entry = function (self, tabl, field, id)
	if not self or not tabl or tabl == "" or not field or not id then
		return false
	end
	local result = false
	
	local passwd_path = self.conf.confdir .. field .. tabl
	local passwdfilecontent = fs.read_file_as_array(passwd_path) or {}
	local output = {}
	for k,v in pairs(passwdfilecontent) do
		if not ( string.match(v, "^".. id .. "[:=]") ) and not string.match(v, "^%s*$") then
			table.insert(output, v)
		else
			result = true
		end
	end
	
	--Save the updated table
	if result == true then
		fs.write_file(passwd_path, table.concat(output,"\n"))
	end

	-- If deleting the main field, delete all other fields also
	if field == "" then
		local fields = list_fields(self, tabl)
		for i,fld in ipairs(fields) do
			delete_entry(self, tabl, fld, id)
		end
	end

	return result
end
