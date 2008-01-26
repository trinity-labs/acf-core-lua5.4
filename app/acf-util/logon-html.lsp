<? local form = ... ?>
<h1>Logon</h1>
<?= html.cfe_unpack(form) ?>

<form action="<?= form.logon.option.script  .. form.logon.option.prefix ..
		form.logon.option.controller .. "/" .. form.logon.option.action ?>" method="POST">
<? local myform = form.logon.value 
 for k,v in pairs(myform) do ?>
	<DT><?= v.name ?></DT>
	<? if v.type == "submit" then ?>
		<DD><input class="submit" type="submit" name="<?= v.name ?>" value="Logon"></DD>
	<? else ?>
		<DD><input class="text" type="text" name="<?= v.name ?>">
		<font color=red><?= v.errtxt ?></font></DD>
	<? end ?>
<? end ?>
</form>
