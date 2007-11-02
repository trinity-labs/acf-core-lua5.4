module (..., package.seeall)

require "fs"


--TODO this should be somehow figureoutable from acf info, help!
local cfgdir = "/usr/share/acf/app/service"

--TODO, in fs actually, find should use coroutines instead of reading
--all in table

local spec = nil

--TODO might on demand load only part of config that is needed for this app
--but then TODO need to make persistent item ids
local function loadCfg()
    if spec ~= nil then return end
    spec = {}
    for fname in fs.find(".*%.srv", cfgdir) do
        f = io.open(fname, 'r')
        if f then
	    s = f:read("*a")
	    f:close()
	    if s then
                c = loadstring("return ({\n" .. s .. "\n})")
	        if c then
		    for i,v in ipairs(c()) do
                        spec[#spec + 1] = v
		    end
		end
	    end
	end
    end
end



local function getAnyPid(pname)
    for e in lfs.dir("/proc") do
        if e == string.match(e, "^%d*$") then
            for line in io.lines("/proc/" .. e .. "/status") do
                tag, val = string.match(line, "^([^:]*):%s*(%S*)$");
                if tag == "Name" then
                    if val == pname then return e end
                    break
                end
            end
        end
    end
end

local mech = {}

function mech.initd(service, action)
    if not service.initd then return false, "no initd" end
    local f = io.popen("/etc/init.d/" .. service.initd .. ' ' .. action, "r")
    if not f then return false, "cannot run initd" end
    local ret = f:read("*a")
    f:close()
    return true, ret
end

function mech.pidfile(svc, action)
    if not service.pidfile then return false end
    if action ~= "status" then return false end
    f = io.open(svc.pidfile)
    if not f then return true, false end
    pid = tonumber(f:read("*a"))
    f:close()
    if not pid then return true, false end
    f = io.open("/proc/" .. tostring(pid) .. "/status")
    if not f then return true, false end
    if svc.pidcmdname then
        for line in f:lines() do
            k, v = string.match(line, '^([^:]*):%s*(.*)$')
            if k == "Name" then
                return true, (v == svc.pidcmdname)
            end
        end
    end
    f:close()
    return true, true
end

local function serviceAction(service, action)
    if not service[action] then return false, "no such action " .. action end
    return mech[service[action]](service, action)
end

local function getServiceActions(service)
    local ret = {}
    if service.start then ret[#ret + 1] = "start" end
    if service.stop then ret[#ret + 1] = "stop" end
    if service.restart then ret[#ret + 1] = "restart" end
    if service.reload then ret[#ret + 1] = "reload" end
    return ret
end

function list(self, app)
    loadCfg()
    ret = {}
    for k,v in pairs(spec) do
        if v.app == app then
            ret[#ret+1] = {
                id=k,
                name=v.name,
                descr=v.descr or "",
                status=serviceAction(v, "status"),
                actions=getServiceActions(v)
            }
        end
    end
    return ret
end

function update(self, id, action)
    loadCfg()
    svc = spec[id]
    if not svc then return false, "no service" end
    return serviceAction(svc, action)
end

