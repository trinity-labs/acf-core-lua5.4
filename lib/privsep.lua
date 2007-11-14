
module(..., package.seeall)

require("json")
require("posix")

local rpc = {}

-- private privileged rpc server ------------------------------------
local function rpcserver(r, w)
	for line in r:lines() do
		local handle = json.decode(line)
		if type(rpc[handle.func]) == "function" then
			response = rpc[handle.func](unpack(handle.data))
		else
			response = nil
		end
		w:write(json.encode(response).."\n")
		w:flush()
	end
end


-- public func ---------------------------------------------------- 
function drop_privs(user, group, privileged_funcs)
	local k, v
	local wrapper = {}

	-- communication pipes
	local cr, pw = posix.pipe()
	local pr, cw = posix.pipe()

	-- create wrapper table
	for k,v in pairs(privileged_funcs or {}) do
		if type(v) == "function" then
			rpc[k] = v
			wrapper[k] = function(...)
				local handle = {}
				handle.func = k
				handle.data = {...}
				cw:write(json.encode(handle).."\n")
				cw:flush()
				return (json.decode(cr:read("*line")))
			end
		end
	end
			
	pid = posix.fork()
	if pid == nil then
		cr:close()
		cw:close()
		pr:close()
		cw:close()
		return nil
	end

	if pid == 0 then
		-- child runs with privs
		cr:close()
		cw:close()
		rpcserver(pr, pw)
		pw:close()
		pr:close()
		os.exit()
	end

	-- lets drop privs
	if posix.setpid("g", group) and	posix.setpid("u", user) then
		return wrapper
	else
		posix.kill(pid)
		return nil
	end
end

