--[[ lowlevel html functions 
     Written for Alpine Configuration Framework (ACF) -- see www.alpinelinux.org
     Copyright (C) 2007  Nathan Angelacos
     Licensed under the terms of GPL2
]]--
module (..., package.seeall)

--[[ Cookie functions ]]------------------------------------------------------
cookie={}

-- Set a cookie - returns a string suitable for setting a cookie
-- if the value is the boolean "false", then set the cookie to expire
cookie.set = function ( name, value, path )
	local expires = ""
	if name == nil then
		return ("")
	end
	if value == false then
		expires = 'expires=Thu Jan  1 00:00:00 EST 1970'
		value = ""
	end
	if path == nil then
		path = "/"
	end
	return (string.format('Set-Cookie: %s=%s; path=%s; %s\n', tostring(name), 
		tostring(value), path, expires))
end


-- wrapper function to clear a cookie
cookie.unset = function ( name, path)
	return cookie.set (name, false, path)
end



-- escape unsafe html characters
function html_escape (text )
	text = text or "" 
	local str = string.gsub (text, "&", "&amp;" )
	str = string.gsub (str, "<", "&lt;" )
	return string.gsub (str, ">", "&gt;" )
end

--  return a name,value pair as a string.  
local nv_pair = function ( name, value)
	if ( name == nil ) then
		return ( value or "" )
	end
	
	if ( type(value) == "boolean" ) then
		value = tostring(value)
	end
	
	if ( value == nil ) then
		return ( "" )
	else
		return (string.format (' %s="%s" ', name , ( value or "" ) ))
	end
end


--[[
	each of these functions take a table that has an associative array of 
	the values we might care about:

	value -- this is the value in the form element, or the selected element
	name -- this is the name of the element
	cols, rows
	class
	id
	etc.
]]--

local generic_input = function ( field_type, v )
	if type(v.value) == "table" then
		ret = {}
		local vals = v.value
		for n, val in ipairs(vals) do
			v.value = val
			table.insert(ret, generic_input(field_type, v))
		end
		v.value = vals
		return table.concat(ret)
	end
	if ( field_type == nil ) then 
		return nil
	end
	
	local str = string.format ( '<input class="%s" type="%s" ', field_type,field_type )

	for i,k in ipairs ( {
			"name", "size", "checked", "maxlength", 
			"value", "length",   "class", "id", "src",
			"align", "alt", "contenteditable", 
			"tabindex", "accesskey", "onfocus", "onblur"
			} ) do
		str = str .. nv_pair ( k, v[k] )
	end

	if ( v.disabled ~= nil ) then 
		str = str .. " disabled"
	end

	return ( str .. ">" )
end
	
	
--[[ Form functions ]]------------------------------------------------------
-- These expect something like a cfe to work (see mvc.lua)

form = {}
form.text = function ( v )
	return generic_input ( "text", v )
end


form.longtext = function ( v )
	local str = "<textarea"
	for i,k in ipairs ( {
				"name", "rows", "cols",
				"class", "id", "tabindex", "accesskey", 
				"onfocus", "onblur" 
			} ) do
		str = str .. nv_pair ( k, v[k] )
	end
	str = str .. nv_pair (nil, v.disabled)
	return ( str .. ">" .. (v.value or "" ) .. "</textarea>" )
end


function form.password ( v )
	return generic_input ( "password", v )
end

function form.hidden ( v )
	return generic_input ( "hidden", v )
end


function form.submit ( v )
	return generic_input ( "submit", v )
end


function form.action (v) 
	return generic_input ("submit", v)
end

function form.file ( v )
	return generic_input ( "file", v )
end

function form.image ( v )
	return generic_input ( "image", v )
end


-- v.value is the selected item (or an array if multiple)
-- v.option is an array of valid options
-- NOTE use of value and values (plural)
function form.select ( v )
	if ( v.name == nil ) then 
		return nil 
	end
	local str = "<select"
	for i,k in ipairs ( {
			"name", "size", "tabindex", "accesskey", 
			"onfocus", "onblur", "onchange", "id", 
			"class", "multiple"
			} ) do
		str = str .. nv_pair ( k, v[k] )
	end
	
	if ( v.disabled ~= nil ) then
		str = str .. " disabled"
	end
	str = str .. ">"
	-- now the options
	local reverseval = {}
	if type(v.value) == "table" then
		for x,val in ipairs(v.value) do
			reverseval[val]=x
		end
	end
	local selected = false
	for i, k in ipairs ( v.option ) do
		local val = k
		local txt = nil
		if type(val) == "table" then
			txt=val[1]
			val=val[0]
		end
		str = str .. "<option "
		if type(v.value) == "table" then
			if reverseval[val] then
				str = str .. " selected"
				selected = true
			end
		elseif ( v.value == val ) then
			str = str .. " selected"
			selected = true
		end
		str = str .. nv_pair("value", val) .. ">" .. k .. "</option>"
	end
	if not selected then
		str = str .. '<option selected value="' .. v.value ..'">[' .. v.value .. ']</option>'
	end
	str = str .. "</select>"
	return (str)
end

function form.checkbox ( v )
       	return generic_input ( "checkbox", v )
end


-- NOTE:  VALUE of a form is a table containing the form elements ... 
function form.start ( v)
	if ( v.action == nil ) then 
		return nil 
	end
	
	local method = v.method or "get"
	return ( string.format (
			'<form %s%s%s>',
			nv_pair ( "class", v.class ), 
			nv_pair ( "method", v.method), 
			nv_pair (	"action", v.action )
		) )
end
	
function form.stop ( )
	return ("</form>")
end

-- For "h1, h2, p," etc 
-- WARNING - Text is printed verbatim - you may want to
-- wrap the text in html_escape
function entity (tag, text, class, id)
	return ( string.format (
			"<%s%s%s>%s</%s>",
			tag, 
			nv_pair ("class", class),
			nv_pair("id", id), text , tag)
		)
end
	 

function link ( v ) 
	if ( v.value == nil ) then
		return nil
	end
	local str = nv_pair ( "href", v.value )
	for i,k in ipairs( { "class", "id" }) do
		str = str .. nv_pair ( k, v[k] )
	end

	return ( "<a " .. str .. ">" .. (v.label or "" ) .. "</a>" )
end


-- give a cfe and get back a string of what is inside
-- great for troubleshotting and seeing what is really being passed to the view
function cfe_unpack ( a )
	if type(a) == "table" then
	value = session.serialize("cfe", a)
	value = "<pre>" .. value .. "</pre>"
	return value
	end

end

