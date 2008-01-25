module (..., package.seeall)
require("fs")

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
					local b = string.match ( l, '^%s*%S*%=%"?(.-)%s*%"?%s*$' )
					local optstable = getopts.opts_to_table(b,filter)
					if (optstable) or not (filter) then
						if not (opts) then
							opts = {}
						end
						if (optstable) then
							opts[a] = optstable
							---[[ Next line is DEBUG info. Should be commented out!
							opts[a]["debug"] = b
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
	local optstr = string.match(optstring, "^\"?(.*)%\"?")		-- Filter away leading/trailing "
	if optstr then
	local option = ""
	local optvalue = ""
		for j = 1, string.len(optstr) do
		if (string.sub(optstr, j, j) == "-%a%s") then
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
