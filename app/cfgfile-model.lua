module (..., package.seeall)

require "fs"


--TODO this should be somehow figureoutable from acf info
local cfgdir = "/usr/share/acf/app/cfgfile"

--TODO, in fs actually, find should use coroutines instead of reading
--all in table

local files = nil

--TODO might on demand load only part of config that is needed for this app
--but then TODO need to make persistent item ids
local function loadCfg()
    if files ~= nil then return end
    files = {}
    for fname in fs.find(".*%.cfg", cfgdir) do
    print ("LOADING FILE ", fname)
        f = io.open(fname, 'r')
        if f then
	    s = f:read("*a")
	    f:close()
	    if s then
                c = loadstring("return ({\n" .. s .. "\n})")
	        if c then
		    for i,v in ipairs(c()) do
                        files[#files + 1] = v
		    end
		end
	    end
	end
    end
end

function list(self, app)
    loadCfg()
    ret = {}
    for k,v in pairs(files) do
        if v.app == app then
            ret[#ret+1] = {
                id=k,
                app=v.app,
                section=v.section,
                name=v.name,
                descr=v.descr,
            }
	end
    end
    return ret
end

function get(self, id)
    loadCfg()
    local item = files[id]
    if not item then return false end
    local f = io.open(item.filename, "r")
    local n = ""
    if f then
        n = f:read("*a")
        f:close()
    end
    return true, {
        id=cfe{ value=tostring(id) },
        content=cfe{ value=n, type="longtext" },
        name=cfe{ value=item.name }
    }
end


function set(self, id, data)
    loadCfg()
    local item = files[id]
    if not item then return false, date end
    local f = io.open(item.filename, "w")
    if f then
        f:write(data.content.value)
        f:close()
    end
    -- TODO update processing
    return get(self, id)
end


