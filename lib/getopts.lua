module (..., package.seeall)
require("fs")

function setoptsinfile (file, search, option, value)
	local opts = {}
	local newfilecontent = nil
	local filecontent = nil
	opts = getoptsfromfile(file) or {}
	filecontent = fs.read_file(file) or ""
	if (filecontent == "") or (opts[search] == "") or (opts[search] == nil) then
		opts[search] = {}
	end
	if not (search) or not (option) then 
		return fales, nil, "Systeminformation - Invalid usage of function getopts.setoptsinfile()"
	end

	--Change to new value
	opts[search][option] = value

	local optstr = ""
	for k,v in pairs(opts) do
		if (k == search) then
			optstr = optstr.. k .. "=\""
			for kk,vv in pairs(v) do
				optstr = optstr .. kk .. " " .. vv .. " "
			end
			optstr = string.match(optstr, "(.-)%s*$") .. "\""
		end
	end

	newfilecontent = string.gsub(filecontent, "%s*[;#]?" .. search .. "%s*=.-\n?$", "\n" .. optstr .. "\n") or ""
	if (string.find(newfilecontent, search .. "%s*=" ) == nil) or (newfilecontent == "") then
		fs.write_file(file,string.match(filecontent, "(.-)\n*$") .. "\n" .. optstr .. "\n")
	else
		fs.write_file(file,string.match(newfilecontent, "(.-)\n*$"))
	end
	return true, "File '" .. file .. "' has been modifyed!", nil
end

function getoptsfromfile (file, search, filter)
	local opts = nil
	if not (fs.is_file(file)) then return nil end
	local conf_file = fs.read_file_as_array ( file )
	for i=1,table.maxn(conf_file) do
		local l = conf_file[i]
		if not string.find ( l, "^[;#].*" ) then
			local a = string.match ( l, "^%s*(%S*)=" )
			if (a) then
				if not (search) or (search == a) then
					local b = string.match ( l, '^%s*%S*%s*%=%s*%"?(.-)%s*%"?%s*$' )
					local optstable = getopts.opts_to_table(b,filter)
					if (optstable) or not (filter) then
						if not (opts) then
							opts = {}
						end
						if (optstable) then
							opts[a] = optstable
							---[[ Next line is DEBUG info. Should be commented out!
							--opts[a]["debug"] = b
							-- End debug info. --]] 
						else
							opts[a] = b
						end
					end
				end
			end
		end
	end
	return opts
end

function opts_to_table ( optstring, filter )
	local optsparams = nil
	local optstr = optstring
	if optstr then
		local option = ""
		for j = 1, string.len(optstr) do
			if (string.find(string.sub(optstr, j, string.len(optstr)), "^-%a%s*")) then
			option=string.sub(optstr, j, j+1)
				if not (filter) or (filter == option) then
					for k = j+1, string.len(optstr) do
						if not (optsparams) then
							optsparams = {}
						end
						if (string.sub(optstr, k, k) == "-") then
							optsparams[option] = string.match(string.sub(optstr, j+2, k-1),"^%s*(.-)%s*$")
							break
						end
						if (k == string.len(optstr)) then
							optsparams[option] = string.match(string.sub(optstr, j+2, k),"^%s*(.-)%s*$")
							break
						end
					end
				end
			end
		end
	end
	return optsparams
end
function getoptsfromfile_onperline (file, search, filter)
	local opts = nil
	if not (fs.is_file(file)) then return nil end
	local conf_file = fs.read_file_as_array ( file )
	for i=1,table.maxn(conf_file) do
		local l = conf_file[i]
		if not string.find ( l, "^[;#].*" ) then
			local a = string.match ( l, "^%s*(%S*)=" )
			if (a) then
				if not (search) or (search == a) then
					local b = string.match ( l, '^%s*%S*%s*%=%s*%"?(.-)%s*%"?%s*$' )
--					local optstable = getopts.opts_to_table(b,filter)
					if not (filter) then
						if not (opts) then
							opts = {}
						end
						opts[a] = b
					end
				end
			end
		end
	end
	return opts
end
