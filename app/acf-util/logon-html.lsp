<% local form, viewlibrary, page_info, session = ... %>
<% require("htmlviewfunctions") %>

<script type="text/javascript" src="<%= html.html_escape(page_info.wwwprefix) %>/js/jquery-latest.js"></script>
<script type="text/javascript">
        $(function(){
		$("input[name='userid']").focus();
	});
</script>

<h1><%= html.html_escape(form.label) %></h1>
<%
	form.value.password.type = "password"
	form.value.redir.type = "hidden"
	local order = { "userid", "password" }
	htmlviewfunctions.displayform(form, order)
%>
