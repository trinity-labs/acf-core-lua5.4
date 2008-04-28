<? local view= ... ?> 
<? --[[
	io.write(html.cfe_unpack(view))
--]] ?>
<h1>User Status </h1>
<p> Below is your current Session id <p>
<?= view.value.sessionid.value ?>
<p>You are currently known to the system as <?= view.value.username.value ?>.</p>
