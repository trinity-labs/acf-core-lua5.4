--[[ 
	middle level functions for the webconf view templates. Part of
	acf

	Copyright (C) 2006 N. Angelacos     Licensed under terms of GPL2 
]]--

module ( ..., package.seeall )

require ("html")

-- This is the main function that walks a table formatted for a template
-- (This is the magic in generic)
function render_table ( element, level) 
	local level = level or 1
	
	if (type(element) ~= "table" ) then 
		return nil 
	end
	
	for k,v in pairs (element) do
		if ( v.type ~= nil ) then
			if ( v.type == "group" ) then
				print ( html.entity ( ( "h" .. tostring(level) ), v.label, v.class, v.id ) )
				print ( html.entity ( "p" , v.text, v.class ) )
				render_table ( v.value, level + 1 )
			elseif ( v.type == "label" ) then
				print ( html.entity ( "h" .. level , v.value, v.class, v.id ) )
				if ( v.text ~= nil ) then
					print ( html.entity ( "p", v.text, v.class ))
				end
			elseif ( v.type == "html" ) then 
				print (v.value)
			elseif ( v.type == "log" ) then
				print("<pre>")
				if type(v.lines) == "function" then
					for line in v.lines do
						print(line)
					end
				elseif v.lines then
					print(v.lines)
				end
				print("</pre>")
			elseif ( v.type == "link" ) then
				print (html.link ( v ) )
			elseif ( v.type == "form" ) then
				print ( html.form.start ( v ) )
				print ("<dl>")
				render_table ( v.value, level + 1 )
				print ("</dl>")
				print ( html.form.stop () )
			elseif type(html.form[v.type]) ~= "nil" then
				if v.type == "hidden" then
					v.noitem = true
				end
				if not v.noitem then
					print ( string.format ("<dt>%s</dt><dd>", ( v.label or "" )))
				end
				print ( html.form[v.type] ( v ) )
				if not v.noitem then
					print ("</dd>")
				end
			end			
		end	
	end
end	


-- This function prints the main menu, with the given prefix/controller "selected"
-- returns the group, category, subcat that is selected
function render_mainmenu ( menu, prefix, controller, action )
	-- prefix+controller defines which menu is "selected"
	local megroup = nil
	local mecat  = nil
	local mesubcat = nil
	local liston = nil
	local group = ""
	local cat = ""
	
	-- find the current group/cat/subcat
	for i=1,table.maxn(menu) do
		if (menu[i].prefix == prefix) and ( menu[i].controller == controller ) then
			megroup = menu[i].group
			mecat = menu[i].cat
			if ( menu[i].action == action ) then
				mesubcat = menu[i].subcat
			elseif ( menu[i].action == "*" ) and ( mesubcat == nil ) then
				mesubcat = menu[i].subcat
			end
		end
	end

	-- render the mainmenu
	local thisgroup = ""
	local thiscat = ""
	for i=1,table.maxn(menu),1 do
		if menu[i].group ~= thisgroup then
			thisgroup = menu[i].group
			if ( liston ) then io.write ("</ul>") end
			print ( html.entity ( "h3", menu[i].group ) )
			io.write("<ul>")
			liston = true
			thicat = nil
		end
		if menu[i].cat ~= thiscat then
			thiscat = menu[i].cat
			if (thiscat == mecat ) then
				print ( html.entity ("li", html.html_escape(thiscat), nil, "selected"))
			else
				print (html.link ( { value= ENV.SCRIPT_NAME .. menu[i].uri ,
				label = html.entity ("li", html.html_escape(thiscat)) } ) )
			end
		end
	end
	io.write ("</ul>")
	return megroup, mecat, mesubcat
end



-- This function prints the tabs for the submenu, with the given submenu "selected"
function render_submenu ( menu,  group, cat, subcat )
	cat = cat or ""
	group = group or ""
	local this_subcat = nil
	local foo = group .. " > " .. cat
	if (foo ~= " > " ) then
		print ( html.entity ( "h2", html.html_escape( group .. " > " .. cat ) ))
	end


	-- print (string.format ("%s - %s - %s", group, cat , (subcat or "")))

	io.write ("<ul>")
	for i=1, table.maxn(menu),1 do
		if  ( group  == menu[i].group ) and ( cat == menu[i].cat ) then
			-- If a subcat was not selected, make the first one the default
			if ( subcat == nil ) then
				subcat = menu[i].subcat
			end

			if ( menu[i].subcat ~= this_subcat ) then
			   	this_subcat = menu[i].subcat
				if ( menu[i].subcat == subcat ) then
			   		print ( html.entity ("li", menu[i].subcat, nil, "selected"))
				else
					io.write ("<li>")
					io.write (  html.link ( { value= ENV.SCRIPT_NAME .. menu[i].uri ,
							      label =menu[i].subcat  } ) )
					print ("</li>")
				end
			end		   	
		end
	end
	io.write ("</ul>")
end
