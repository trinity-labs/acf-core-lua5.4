
module (..., package.seeall)
require("bit")

function iptoint(str)
	-- TODO: support "a.", "a.b.", "a.b.c."
        local a,b,c,d = string.match(str, "(%d+).(%d+).(%d+).(%d+)")
        if a and b and c and d then
		return bit.lshift(a, 24) + bit.lshift(b, 16) + bit.lshift(c, 8) + d
        end
        return nil
end

function nettoint(net, mask)
	if mask == nil then
		mask = string.match(net, "/(.*)")
		if mask == nil then
			-- no mask provied at all
			return iptoint(net)
		end
		net = string.gsub(net, "/.*", "")
	end

	local n = tonumber(mask)
	if n == nil then
		-- mask is a.b.c.d style
		return iptoint(net), iptoint(mask)
	end

	-- mask is /24 style
	if n > 32 then
		return nil
	end
	return iptoint(net), bit.band(bit.lshift(0xfffffffff, 32 - n), 0xffffffff)
end
		

-- same_subnet - check if address is in net/mask
-- synopsis:
-- 	same_subnet(addr, net[/mask][, mask])
-- example:
-- 	same_subnet("10.0.0.1", "10.0.0.0/24")
-- 	same_subnet("10.0.0.1", "10.0.0.0", "24")
-- 	same_subnet("10.0.0.1", "10.0.0.0/255.255.255.0")
-- 	same_subnet("10.0.0.1", "10.0.0.0", "255.255.255.0")

function same_subnet(addr, net, mask)
	local a = iptoint(addr)
	local n, m = nettoint(net, mask)
	if a and n and m then
		return bit.band(a, m) == bit.band(n, m)
	end
	return false
end

