<? local form = ... ?>
<? --[[
       io.write(html.cfe_unpack(form))
   --]] ?>

<? if form.errtxt ~= "" then ?>
<h1>Command Result</h1>
<p class='error'> <?= form.errtxt ?></p>
<? end ?>

<h1>Logon</h1>
<form action="logon" method="POST">
<DL>
	<DT>User id</DT>
		<DD><input class="text" type="text" name="userid" value="<?= form.value ?>"></DD>
	<DT>Password</DT>
		<DD><input class="password" type="password" name="password" value=""></DD>
	<DT><input class="submit" type="submit" name="Logon" value="Logon"></DD>
</DL>
</form>
