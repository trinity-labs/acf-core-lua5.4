module (..., package.seeall)

-- Public methods

default_action = "read"

read = function (self )
	return self.model.get(self)
end

update = function (self )
	return self.handle_form(self, self.model.get_update, self.model.update, self.clientdata, "Update", "Update Skin", "Skin updated")
end

