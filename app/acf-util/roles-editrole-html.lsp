<? local form, viewtable, pageinfo = ... ?> 
<? --[[
	io.write(html.cfe_unpack(form))
	io.write(html.cfe_unpack(FORM))
--]] ?>

<? ---[[ ?>
<H1><?= form.label ?></H1>
<?
	require("viewfunctions")
	form.action = ""
	form.submit = "Save"
	-- If editing existing role, disable role
	if pageinfo.action ~= "newrole" then
		form.value.role.contenteditable = false
	end
	local order = { "role", "permissions" }
	displayform(form, order)
?>
<? --]] ?>
