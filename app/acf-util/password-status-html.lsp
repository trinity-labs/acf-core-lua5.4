<? local form = ... ?>
<?
--[[ DEBUG INFORMATION
io.write("<H1>DEBUGGING</H1><span style='color:red'><H2>DEBUG INFO: CFE</H2>")
io.write(html.cfe_unpack(form))
io.write("</span>")
--]]
?>

<?
function displayinfo(myform,tags,viewonly)
	io.write("<DL>")
	for k,v in pairs(tags) do 
		if (myform[v]) and (myform[v]["value"]) then
			local val = myform[v] 
			io.write("\t<DT")
			if (#val.errtxt > 0) then 
				val.class = "error"
				io.write(" class='error'")
			end
			io.write(">" .. val.label .. "</DT>\n")
			if (viewonly) then
				io.write("\t\t<DD>" .. val.value .. "\n")
			else
				io.write("\t\t<DD>" .. html.form[val.type](val) .. "\n")
			end
			if (val.descr) and (#val.descr > 0) then io.write("\t\t<P CLASS='descr'>" .. string.gsub(val.descr, "\n", "<BR>") .. "</P>\n") end
			if (#val.errtxt > 0) then io.write("\t\t<P CLASS='error'>" .. string.gsub(val.errtxt, "\n", "<BR>") .. "</P>\n") end
			io.write("\t\t</DD>\n")
		end
	end
	io.write("</DL>")
end
?>

<H1>USER ACCOUNTS</H1>
<H2>Create new account</H2>
<form name="createnew" action="" method="POST">
<? 
local myform = form.status
local tags = { "cmdnew", }
displayinfo(myform,tags)
?>
</form>
<H2>Existing account</H2>
<?
--function displayinfo(myform,tags,viewonly)
local myform = form.status.users

io.write("<DL>")
if (type(myform) == "table") then
	for k,v in pairs(myform) do
		local myform = myform[k]
		io.write("\t<DT")
		if (#myform.errtxt > 0) then 
			myform.class = "error"
			io.write(" class='error'")
		end
		io.write("><IMG SRC='/static/tango/16x16/apps/system-users.png' HEIGHT='16' WIDTH='16'> " .. myform.label .. "</DT>\n")
		io.write("\t\t<DD>\n\t\t<TABLE>")
		io.write("\n\t\t\t<TR>\n\t\t\t\t<TD><B>".. myform.value.userid.label .."</B></TD>\n\t\t\t\t<TD WIDTH='90%'>" .. myform.value.userid.value .. "</TD>\n\t\t\t</TR>")
		io.write("\n\t\t\t<TR>\n\t\t\t\t<TD><B>".. myform.value.username.label .."</B></TD>\n\t\t\t\t<TD>" .. myform.value.username.value .. "</TD>\n\t\t\t</TR>")
		io.write("\n\t\t\t<TR>\n\t\t\t\t<TD><B>".. myform.value.roles.label .."</B></TD>\n\t\t\t\t<TD>" .. myform.value.roles.value .. "</TD>\n\t\t\t</TR>")
		io.write("</TD>\n\t\t\t</TR>")
		io.write("\n\t\t\t<TR>\n\t\t\t\t<TD><B>Option</B></TD>\n\t\t\t\t<TD>[<A HREF='administrator?userid=".. myform.value.userid.value .. "'>Edit this account</A>]</TD>\n\t\t\t</TR>")
		io.write("\n\t\t</TABLE>\n")
		if (#myform.errtxt > 0) then io.write("\t\t<P CLASS='error'>" .. string.gsub(myform.errtxt, "\n", "<BR>") .. "</P>\n") end
		io.write("\t\t</DD>\n")
	end
end
io.write("</DL>")
?>


<?
---[[ DEBUG INFORMATION
io.write("<H1>DEBUGGING</H1><span style='color:red'><H2>DEBUG INFO: CFE</H2>")
io.write(html.cfe_unpack(form))
io.write("</span>")
--]]
?>

