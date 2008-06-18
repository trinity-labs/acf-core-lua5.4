--------------------------------------------------
-- Validation Functions for Alpine Linux' Webconf
--------------------------------------------------
module (..., package.seeall)

-- setup the 'language' table
lang = {}
lang.English = 1
lang.German  = 2
lang.French  = 3
lang.Current = lang.English

-- setup the 'validator' tables
validator = {}
validator.msg = {}
validator.msg.err = {}

-- setup error messages
validator.msg.err.Success = {}
validator.msg.err.Success[lang.English]        = "Ok."
validator.msg.err.Success[lang.German]         = "Ok."
validator.msg.err.InvalidChars = {}
validator.msg.err.InvalidChars[lang.English]   = "Invalid characters!"
validator.msg.err.InvalidChars[lang.German]    = "Ungültige Zeichen!"
validator.msg.err.InvalidLength = {}
validator.msg.err.InvalidLength[lang.English]  = "Invalid length!"
validator.msg.err.InvalidLength[lang.German]   = "Ungültige Länge!"
validator.msg.err.InvalidFormat = {}
validator.msg.err.InvalidFormat[lang.English]  = "Invalid format!"
validator.msg.err.InvalidFormat[lang.German]   = "Ungültiges Format!"
validator.msg.err.InvalidValue = {}
validator.msg.err.InvalidValue[lang.English]   = "Invalid Value!"
validator.msg.err.InvalidValue[lang.German]    = "Ungültiger Wert!"
validator.msg.err.OutOfRange = {}
validator.msg.err.OutOfRange[lang.English]     = "Value out of range!"
validator.msg.err.OutOfRange[lang.German]      = "Wert ausserhalb des Bereichs!"

validator.msg.err.FileInvalidPath1 = {}
validator.msg.err.FileInvalidPath1[lang.English]	= "Not a valid path!"
validator.msg.err.FileInvalidPath2 = {}
validator.msg.err.FileInvalidPath2[lang.English]	= "You are restrected to"


function is_string ( str )
	if type(str) == "string" then
	return true, str, "Is a string."
	else
	return false, str, "Is not a string."
	end
end

function is_boolean ( str )
	if type(str) == "boolean" then
	return true, str, "Is a boolean."
	else
	return false, str, "Is not a boolean."
	end
end

function is_number ( str )
	if type(str) == "number" then
	return true, str, "Is a number."
	else
	return false, str, "Is not a number."
	end
end

--
-- This function validates an ipv4 address.
-- On success it returns 1 otherwise a negative value
--
function is_ipv4(ipv4)
	local retval = false;
	local nums = {};
	local iplen = string.len(ipv4);

	-- check the ipv4's length
	if (iplen < 7 or iplen > 15) then
		return false, validator.msg.err.InvalidLength[lang.Current]
	end

	-- NC: Split the string into an array. separate with '.' (dots)
	-- ^	beginning of string
	-- ()	capture
	-- %.	litteral '.' The % neutralizes the . character class.
	-- %d+	one or more digits
	-- $	end of string
	nums = {ipv4:match ("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")}
	
	-- check if all nums are filled
	if ( nums[1] == nil or
		nums[2] == nil or
		nums[3] == nil or
		nums[4] == nil) then
		-- we have an empty number
		return false, validator.msg.err.InvalidFormat[lang.Current]
	end

	-- too big?
	if (tonumber(nums[1]) > 255 or
			tonumber(nums[2]) > 255 or
			tonumber(nums[3]) > 255 or
			tonumber(nums[4]) > 255) then
		-- at least one number is too big
		return false, validator.msg.err.InvalidValue[lang.Current]
	end
	
	return true, validator.msg.err.Success[lang.Current]
end

function is_mac(mac)

	local tmpmac = string.upper(mac)

	if (string.len(tmpmac) ~= 17) then
		return false, validator.msg.err.InvalidLength[lang.Current]
	end

	-- check for valid characters
	local step = 1;
	while (step <= 17) do
		if (string.sub(tmpmac, step, step) ~= ":") and 
			 (string.sub(tmpmac, step, step) < "0" or string.sub(tmpmac, step, step) > "9") and 
			 (string.sub(tmpmac, step, step) < "A" or string.sub(tmpmac, step, step) > "F") then
			-- we have found an invalid character!
			return false, validator.msg.err.InvalidChars[lang.Current]
		end
		step = step + 1;
	end

	-- check for valid colon positions
	if (string.sub(tmpmac, 3, 3) ~= ":" or
			string.sub(tmpmac, 6, 6) ~= ":" or
			string.sub(tmpmac, 9, 9) ~= ":" or
			string.sub(tmpmac, 12, 12) ~= ":" or
			string.sub(tmpmac, 15, 15) ~= ":") then
		return false, validator.msg.err.InvalidFormat[lang.Current]
	end

	-- check for valid non colon positions
	step = 1;
	while (step <= 17) do
		if ((string.sub(tmpmac, step, step) == ":") and
				((step ~= 3) and (step ~= 6) and (step ~= 9) and (step ~= 12) and 
				 (step ~= 15))) then
			return false, validator.msg.err.InvalidValue[lang.Current]
		end
		step = step + 1;
	end

	return true, validator.msg.err.Success[lang.Current]
end

--
-- This function checks if the given input 
-- consists of number-chars between 0..9 only
-- and eventually a leading '-'
--
function is_integer(numstr)
	-- ^   beginning of string
	-- -?  one or zero ot the char '-'
	-- %d+ one or more digits
	-- $   end of string
	return string.find(numstr, "^-?%d+$") ~= nil
end


--
-- This function checks if the given input 
-- consists of number-chars between 0..9 only
-- and if it is within a given range.
--
function is_integer_in_range(numstr, min, max)
	return  is_integer(numstr) 
		and tonumber(numstr) >= min
		and tonumber(numstr) <= max
	
end

--
-- This function checks if the given number is an integer
-- and wheter it is between 1 .. 65535
--
function is_port(numstr)
	return  is_integer_in_range(numstr, 1, 65535)
end

function is_valid_filename ( path, restriction )
	if not (path) or ((restriction) and (string.find (path, "^" .. restriction ) == nil)) then
		return false, "* " .. validator.msg.err.FileInvalidPath1[lang.Current] .. "\n* ".. 
			validator.msg.err.FileInvalidPath2[lang.Current] .. ":" .. string.format(restriction)
	end
	return true, path
end
