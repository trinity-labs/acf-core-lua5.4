<% local view= ... %> 
<% html = require("acf.html") %>

<% if view.value.userid then %>
	<H1>Roles/Permission list for <%= html.html_escape(view.value.userid.value) %>:</H1>
<% elseif view.value.role then %>
	<H1>Permission list for <%= html.html_escape(view.value.role.value) %>:</H1>
<% else %>
	<H1>Complete permission list:</H1>
<% end %>

<% if view.value.roles then %>
	<H2><%= html.html_escape(view.value.userid.value) %> is valid in these roles</H2>
	<DL>
	<% for a,b in pairs(view.value.roles.value) do
		print("<dt>",html.html_escape(b),"</dt><dd>&nbsp;</dd>")
	end %>
	</DL>
<% end %>

<% if view.value.permissions then %>
	<% if view.value.userid then %>
		<H2><%= html.html_escape(view.value.userid.value) %>'s full permissions are</H2>
	<% elseif view.value.role then %>
		<H2><%= html.html_escape(view.value.role.value) %>'s full permissions are</H2>
	<% end %>
	<DL>
	<TABLE>
		<TR><TD CLASS='header'>Controller</TD><TD CLASS='header'>Action(s)</TD></TR>
		<% local prefixes = {}
		-- It's nice to have it in alphabetical order
		for pref in pairs(view.value.permissions.value) do
			prefixes[#prefixes + 1] = pref
		end
		table.sort(prefixes)
		for w,pref in ipairs(prefixes) do
			local controllers = {}
			-- Again, alphabetical order
			for cont in pairs(view.value.permissions.value[pref]) do
				controllers[#controllers + 1] = cont
			end
			table.sort(controllers)
			for x,cont in ipairs(controllers) do
				print("<TR><TD STYLE='font-weight:bold;'>",html.html_escape(pref..cont),"</TD><TD>")
				-- Again, alphabetical order
				local actions = {}
				for act in pairs(view.value.permissions.value[pref][cont]) do
					actions[#actions + 1] = act
				end
				table.sort(actions)
				for y,act in pairs(actions) do
					print((html.html_escape(act)))
				end
				io.write("<TD></TR>")
			end
		end
		%>
	</TABLE>
	</DL>
<% end %>
