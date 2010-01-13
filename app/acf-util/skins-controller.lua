module (..., package.seeall)

-- Public methods

default_action = "read"

read = function (self )
	return self.model.get(self)
end

update = function (self )
	return self:redirect_to_referrer(self.model.update(self, self.clientdata.skin or ""))
end

