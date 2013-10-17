local mymodule = {}

-- Public methods

mymodule.default_action = "read"

mymodule.read = function (self )
	return self.model.get(self)
end

mymodule.update = function (self )
	return self.handle_form(self, self.model.get_update, self.model.update, self.clientdata, "Update", "Update Skin", "Skin updated")
end

return mymodule
