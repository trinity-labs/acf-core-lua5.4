<% local view, viewlibrary, page_info, session = ... %>
<% html = require("acf.html") %>

<script type="text/javascript">
        if (typeof jQuery == 'undefined') {
		document.write('<script type="text/javascript" src="<%= html.html_escape(page_info.wwwprefix) %>/js/jquery-latest.js"><\/script>');
	}
</script>

<script type="text/javascript">
	if (typeof $.tablesorter == 'undefined') {
		document.write('<script type="text/javascript" src="<%= html.html_escape(page_info.wwwprefix) %>/js/jquery.tablesorter.js"><\/script>');
	}
</script>

<script type="text/javascript">
	$(document).ready(function() {
		$("#permissions").tablesorter({widgets: ['zebra']});
	});
</script>

<% if view.value.userid then %>
	<h1>Roles/Permission list for <%= html.html_escape(view.value.userid.value) %>:</h1>
<% elseif view.value.role then %>
	<h1>Permission list for <%= html.html_escape(view.value.role.value) %>:</h1>
<% else %>
	<h1>Complete permission list:</h1>
<% end %>

<% if view.value.roles then %>
	<h2><%= html.html_escape(view.value.userid.value) %> is valid in these roles</h2>
	<% for a,b in pairs(view.value.roles.value) do
		print("<p>",html.html_escape(b),"</p>")
	end %>
<% end %>

<% if view.value.permissions then %>
	<% if view.value.userid then %>
		<h2><%= html.html_escape(view.value.userid.value) %>'s full permissions are</h2>
	<% elseif view.value.role then %>
		<h2><%= html.html_escape(view.value.role.value) %>'s full permissions are</h2>
	<% end %>
	<table id="permissions" class="tablesorter"><thead>
		<tr><th>Controller</th><th>Action(s)</th></tr>
	</thead><tbody>
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
				print("<tr><td style='font-weight:bold;'>",html.html_escape(pref..cont),"</td><td>")
				-- Again, alphabetical order
				local actions = {}
				for act in pairs(view.value.permissions.value[pref][cont]) do
					actions[#actions + 1] = act
				end
				table.sort(actions)
				for y,act in pairs(actions) do
					print((html.html_escape(act)))
				end
				io.write("</td></tr>")
			end
		end
		%>
	</tbody></table>
<% end %>
