module (..., package.seeall)

-- no initializer in model - use controller.init for that

local function read_file ( path )
	local file = io.open(path)
	if ( file ) then
		local f = file:read("*a") or "unknown"
		file:close()
		return f
	else
		return "Cant find '" .. path .. "'"
	end
end

get = function (self,path)
	local file_content = {}
	file_content = cfe{value=read_file(path), name=path}
	file_name = cfe{value=path, name=file_name}
	return file_content, file_name
end

