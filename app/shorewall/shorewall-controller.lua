module(..., package.seeall)

local list_redir = function(self)
    self.conf.action = "read"
    self.conf.type = "redir"
    error(self.conf)
end

mvc={}
mvc.on_load = function(self, parent)
    --TODO: This needs to be looked at 
    self.cfgfile = self:soft_require("cfgfile-model")
    setmetatable(self.cfgfile, self.cfgfile)
    self.cfgfile.__index = self.worker
    if (self.worker[self.conf.action] == nil) or (self.conf.action == "init") then
        self.worker[self.conf.action] = list_redir(self)
    end
end

-- Public methods
-- <prefix>/hostname/get

read = function(self)
    return {
        list=self.cfgfile:list("firewall"),
        script=ENV["SCRIPT_NAME"],
        prefix=self.conf.prefix,
        controller=self.conf.controller,
        action="update",
   }
end

update = function(self)
    local id = tonumber(self.clientdata.id) or -1
    local result
    local data

    result, data = self.cfgfile:get(id)
    if not result then return list_redir(self) end

    if self.clientdata.cmd then
        for k,v in pairs (data) do
            if self.clientdata[k] then 
                data[k].value = self.clientdata[k]
            end
        end
        result, data = self.cfgfile:set(id, data)
	if result then return list_redir(self) end
    end
                
    data.cmd = cfe { type="action", value="save", label="action" }
    return cfe{ type="form", 
        option={ script=ENV["SCRIPT_NAME"],
            prefix=self.conf.prefix,
            controller = self.conf.controller,
            action = "update",
            extra = ""},
        value = data}
end

--This is a work in progress, do not review
local function mkCtlRet(self)
    return {
        script=ENV["SCRIPT_NAME"],
        prefix=self.conf.prefix,
        controller = self.conf.controller,
        action={
          { name="restart", label="Restart" },
          { name="start", label="Start" },
          { name="stop", label="Stop" },
          { name="reload", label="Reload", disabled=true },
	},
	title="Shorewall",
	text={}
    }
end

restart = function(self)
    ret = mkCtlRet(self)
    if self.clientdata.restart then
        ret.active = "restart"
	local f = io.popen("/etc/init.d/shorewall restart", "r")
	if f then
            local out = f:read("*a")
	    f:close()
	    ret.text[#ret.text + 1] = { label="Restarting", content=out }
	else
	    ret.text[#ret.text + 1] = {
	        label="Error", content="Cannot run /etc/init.d/shorewall"
	    }
	end
    end
    return ret
end

--create = update
--delete = update

