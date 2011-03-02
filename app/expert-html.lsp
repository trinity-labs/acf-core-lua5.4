<% local form, viewlibrary, page_info, session = ... %>
<% require("viewfunctions") %>

<%
local pattern = string.gsub(page_info.prefix..page_info.controller, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
local func = haserl.loadfile(page_info.viewfile:gsub(pattern..".*$", "/") .. "filedetails-html.lsp")
func(form, viewlibrary, page_info, session)
%>
