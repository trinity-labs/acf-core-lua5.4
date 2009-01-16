<% local view= ... %> 
<% --[[
	io.write(html.cfe_unpack(view))
--]] %>

<% ---[[ %>
<% if view.value.userid then %>
	<H1>Roles/Permission list for <%= html.html_escape(view.value.userid.value) %>:</H1>
<% elseif view.value.role then %>
	<H1>Permission list for <%= html.html_escape(view.value.role.value) %>:</H1>
<% else %>
	<H1>Complete permission list:</H1>
<% end %>

<% if view.value.roles then %>
	<H2><%= html.html_escape(view.value.userid.value) %> is valid in these roles</H2>
	<% for a,b in pairs(view.value.roles.value) do
		print("<li>",html.html_escape(b),"</li>")
	end %>
<% end %>
<% --]] %>

<% ---[[ %>
<% if view.value.permissions then %>
	<% if view.value.userid then %>
		<H2><%= html.html_escape(view.value.userid.value) %>'s full permissions are</H2>
	<% elseif view.value.role then %>
		<H2><%= html.html_escape(view.value.role.value) %>'s full permissions are</H2>
	<% end %>
	<% local controllers = {}
	   -- It's nice to have it in alphabetical order
	   for cont in pairs(view.value.permissions.value) do
		controllers[#controllers + 1] = cont
	   end
	   table.sort(controllers)
	   io.write("<TABLE>")
	   io.write("<TR><TD CLASS='header'>Controller</TD><TD CLASS='header'>Action(s)</TD>")
	   for x,cont in ipairs(controllers) do
		print("<TR><TD STYLE='font-weight:bold;'>",html.html_escape(cont),"</TD><TD>")
		-- Again, alphabetical order
		local actions = {}
		for act in pairs(view.value.permissions.value[cont]) do
			actions[#actions + 1] = act
		end
		table.sort(actions)
		for y,act in pairs(actions) do
			print((html.html_escape(act)))
		end
		io.write("<TD></TR>")
	    end
	    io.write("</TABLE>")
	    %>
<% end %>
<% --]] %>
