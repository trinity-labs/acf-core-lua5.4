<? local form = ... ?>
<h1>Logon</h1>
<? --[[ ?>
<?= html.cfe_unpack(form) ?>
<? --]] ?>

<form action="<?= form.logon.option.script  .. form.logon.option.prefix ..
		form.logon.option.controller .. "/" .. form.logon.option.action ?>" method="POST">
<DL>
<?
local myform = form.logon.value 
for k,v in pairs(myform) do
	io.write("\t<DT")
	if (#v.errtxt > 0) then io.write(" class='error'") end
		io.write(">" .. v.label .. "</DT>\n")

			io.write("\t\t<DD>" .. html.form[v.type](v) .. "\n")
		if (v.descr) and (#v.descr > 0) then io.write("\t\t<P CLASS='descr'>" .. string.gsub(v.descr, "\n", "<BR>") .. "</P>\n") end
		if (#v.errtxt > 0) then io.write("\t\t<P CLASS='error'>" .. string.gsub(v.errtxt, "\n", "<BR>") .. "</P>\n") end
		io.write("\t\t</DD>\n")
end 
?>
</DL>
</form>
