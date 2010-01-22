module (..., package.seeall)

require("fs")
require("format")

local function set_skins(self, skin)
	local content = "\n"..(fs.read_file(self.conf.conffile) or "")
	local count
	content,count = string.gsub(content, "\n%s*skin%s*=[^\n]*", "\nskin="..skin)
	if count == 0 then
		content = "\nskin="..skin..content
	end
	fs.write_file(self.conf.conffile, string.sub(content,2))
	local cmdoutput = "New skin selected"
	return cmdoutput, errtxt
end

local function list_skins(self)
	local skinarray = {}
	for skin in string.gmatch(self.conf.skindir, "[^,]+") do
		for i,file in ipairs(posix.dir(self.conf.wwwdir ..skin) or {}) do
			-- Ignore files that begins with a '.' and 'cgi-bin' and only list folders
			if not ((string.match(file, "^%.")) or (string.match(file, "^cgi[-]bin")) or (string.match(file, "^static")) or (posix.stat(self.conf.wwwdir .. skin .. file).type ~= "directory")) then
				local entry = cfe({ value=skin..file, label="Skin name" })
				local current = conf.skin
				entry.inuse = (skin..file == current)
				table.insert(skinarray, entry)
			end
		end
	end
	return cfe({ type="list", value=skinarray, label="Skins" })
end


get = function (self)
	return list_skins(self)
end

update = function (self, newskin)
	-- Make sure no one can inject code into the model.
	local availableskins = list_skins(self)
	local cmdoutput = "Failed to set skin"
	local errtxt = "Invalid selection"
	for i,skin in ipairs(availableskins.value) do
		if ( skin.value == newskin) then
			cmdoutput, errtxt = set_skins(self, newskin)
		end
	end
	return cfe({ value=cmdoutput, errtxt=errtxt, label="Set skin result" })
end
