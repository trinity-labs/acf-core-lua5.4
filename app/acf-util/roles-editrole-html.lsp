<? local form, viewtable, pageinfo = ... ?> 
<? --[[
	io.write(html.cfe_unpack(form))
--]] ?>

<? ---[[ ?>
<H1><?= form.label ?></H1>
<?
	require("viewfunctions")
	-- If editing existing role, disable role
	if pageinfo.action ~= "newrole" then
		form.value.role.contenteditable = false
	end
	local order = { "role", "permissions" }
	displayform(form, order)
?>
<? --]] ?>
