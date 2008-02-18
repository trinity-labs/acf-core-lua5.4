module(..., package.seeall)

local configfile = "/etc/acf/passwd"

-- ################################################################################
-- LOCAL FUNCTIONS

local function get_roles()
	local output = cfe({
		name="roles",
		label="Available roles",
		type="checkbox",
		option={"CREATE","UPDATE","DELETE","READ"},
		})
	return output
end

-- Return a table with the account-details
local function get_usersettings(userid)
	local output = {}
	local filecontent = fs.read_file_as_array(configfile)
	for i=1,table.maxn(filecontent) do
		local l = filecontent[i]
		if not (string.find ( l, "^[;#].*" )) and not (string.find (l, "^%s*$")) then
			local useroptions = format.string_to_table(l,":")
			local userroles = {}
			for k,v in pairs(format.string_to_table(useroptions[4],",")) do
				userroles[v] = true
			end
			if not (userid) or ( (userid) and (userid == useroptions[1]) ) then
				table.insert(output, cfe({ 
					name=useroptions[1],
					value=useroptions[1],
					label=useroptions[1],
					fulltext=string.match(l,"(.-)%s*$"),
	--				password=useroptions[2],
					descr=useroptions[3],
					roles=userroles,
	--				errtxt="Account is locked!",
					}))
			end
		end
	end
	return output
end

--setup so that it will compare password input
local function set (self, userid, cmd1, cmd2) 
	if cmd1 ~= cmd2 then report = "Invalid or non matching password. Try again" 
	else
	command = "/usr/bin/cryptpw" .. " " .. cmd1
	f = io.popen(command)
	c = f:read("*l")
	f:close()
	--this is hardcoded for root should be easy to change
	newpass = "root:" .. c
	t = fs.search_replace("/etc/shadow", "root:[!%w%$%/%.]+", newpass)
	fs.write_file("/etc/shadow", fs.ipairs_string(t))
	report = "Success. New password set."
	end
	return( cfe{value=report, name="report"})
end

-- ################################################################################
-- PUBLIC FUNCTIONS

-- Present some general status
function getstatus()
	local status = {}
	status.users = get_usersettings()

	local roles = ""
	--Rewrite roles into a presentable textstring
	for k,v in pairs(status.users) do
		for kk,vv in pairs(v.roles) do
			roles = kk.. " / " .. roles
		end
		v.roles = roles
		roles = ""
	end
	

--	status.roles = get_roles()
	return status
end

function getsettings(userid)
	local settings = {}
	local usersettings = get_usersettings(userid)

	settings.userid = usersettings[1]
	settings.userid.label = "User id"

	settings.roles = get_roles()

---[[	
	settings.descr = cfe({ 
		name="descr",
		value=usersettings[1].descr,
		label="Description",
--		fulltext=string.match(l,"(.-)%s*$"),
--		password=useroptions[2],
--		descr=useroptions[3],
--		roles=userroles,
--		errtxt="Account is locked!",
		})
--]]
	return settings
end
