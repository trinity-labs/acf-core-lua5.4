<% local view = ... %>

<h1>User Status</h1>

<DL>

<DT><%= html.html_escape(view.value.username.label) %></DT>
<DD><%= html.html_escape(view.value.username.value) %></DD>

<DT><%= html.html_escape(view.value.sessionid.label) %></DT>
<DD><%= html.html_escape(view.value.sessionid.value) %></DD>

</DL>
