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
	io.write("\n<DL>")
	for k,v in pairs(tags) do 
		if (myform[v]) and (myform[v]["value"]) then
			local val = myform[v] 
			io.write("\n\t<DT")
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
			if (#val.errtxt > 0) then io.write("\t\t<P CLASS='error'>" .. string.gsub(val.errtxt, "\n", "<BR>") .. "</P>\n") end
			io.write("\t\t</DD>\n")
		end
	end
	io.write("</DL>")
end
?>

<H1>CONFIG</H1>
<H2>Settings</H2>
<? 
local myform = form.config 
local tags = { "userid", }
displayinfo(myform,tags,"viewonly")
local tags = { "descr", }
displayinfo(myform,tags)
?>

<?
-- The following code is a bit special because I want to display checkboxes for available roles.
local myform = form.config.roles
io.write("\n<DL>")
io.write("\n\t<DT")
if (#myform.errtxt > 0) then 
	myform.class = "error"
	io.write(" class='error'")
end
io.write(">" .. myform.label .. "</DT>")
io.write("\n\t\t<DD>")
for k,v in pairs(myform.option) do
	local checked = ""
	if (form.config.userid.roles[v]) then checked = "checked='yes'" end
	io.write("\n\t\t\t" ..v .. ":<input class='checkbox' type='checkbox'  name='roles'  value='' " .. checked .. "> ")
end
if (#myform.errtxt > 0) then io.write("\t\t<P CLASS='error'>" .. string.gsub(myform.errtxt, "\n", "<BR>") .. "</P>\n") end
io.write("\n\t\t</DD>\n")
io.write("</DL>")
?>

<H2>Actions</H2>
<? 
local myform = form.config 
local tags = { "cmdsave", "cmddelete", }
displayinfo(myform,tags)

?>

