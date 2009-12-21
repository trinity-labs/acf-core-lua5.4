-- A standin controller for testing
module (..., package.seeall)

default_action = "read"

read = function (self )
	return ( {self = self} )
end


