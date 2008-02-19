<? local form = ... ?>
<?
--[[ DEBUG INFORMATION
io.write("<H1>DEBUGGING</H1><span style='color:red'><H2>DEBUG INFO: CFE</H2>")
io.write(html.cfe_unpack(form))
io.write("</span>")
--]]
?>
<?
function displayinfo(myform,tags,viewtype)
	io.write("\n<DL>")
	for k,v in pairs(tags) do 
		if (myform) and (myform[v]) and (myform[v]["value"]) then
			local val = myform[v] 
			if (val.type) and not (val.type == "hidden") then
				io.write("\n\t<DT")
				if (#val.errtxt > 0) then 
					val.class = "error"
					io.write(" class='error'")
				end
				io.write(">" .. val.label .. "</DT>")
				io.write("\n\t\t<DD>")
				if (viewtype == "viewonly") then
					io.write(val.value)
				elseif (viewtype == "roles") then
					for k,v in pairs(form.config.availableroles.option) do
						local checked = ""
						for kk,vv in pairs(form.config.roles.option) do
							if (v == vv) then
								checked = "checked='yes'"
								break
							end
						end
						io.write("\n\t\t\t" ..v .. ":<input class='checkbox' type='checkbox'  name='roles'  value='' " .. checked .. " disabled> ")
					end
				else
					io.write(html.form[val.type](val))
				end
				if (#val.errtxt > 0) then io.write("\t\t<P CLASS='error'>" .. string.gsub(val.errtxt, "\n", "<BR>") .. "</P>") end
				io.write("\n\t\t</DD>")
			else
				io.write(html.form[val.type](val))
			end
		end
	end
	io.write("\n</DL>")
end
?>

<H1>CONFIG</H1>
<H2>Settings</H2>
<form name="settings" action="save" method="POST">
<? 
local myform = form.config 
displayinfo(myform,{ "userid","orguserid", "username" })
displayinfo(myform,{ "roles" },"roles")
displayinfo(myform,{ "password","password_confirm" })
?>

<H2>Actions</H2>
<? 
local myform = form.config 
local tags = { "cmdsave", "cmddelete", }
displayinfo(myform,tags)
?>
</form>

<?
---[[ DEBUG INFORMATION
io.write("<H1>DEBUGGING</H1><span style='color:red'><H2>DEBUG INFO: CFE</H2>")
io.write(html.cfe_unpack(form))
io.write("</span>")
--]]
?>
