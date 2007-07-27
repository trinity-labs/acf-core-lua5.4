<? local form = ... ?>
<h1>Logon</h1>

<form action="<?= form.option.script  .. form.option.prefix ..
		form.option.controller .. "/" .. form.option.action ?>" method="POST">
<table>
<? local myform = form.value 
 for k,v in pairs(myform) do ?>
<tr><td><?= v.name ?></td><td>
<? if v.type == "submit" then ?>
	<input type="submit" name="<?= v.name ?>" value="Logon">
<? else ?>
	<input type="text" name="<?= v.name ?>">
	<font color=red><?= v.errtxt ?></font>
<? end ?>
</td></tr>
<? end ?>
</table>
</form>
