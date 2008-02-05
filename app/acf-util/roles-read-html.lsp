<? local view= ... ?> 
<h1>Role Views</h1>
<p>Roles/Permission list for <?= view.read.userid.value ?>:<p>

<p>You are valid in these role <p>
<? for a,b in pairs(view.read.roles.value) do 
print("<li>",b) end ?>

<p>Your full permissions are<p>
<?= view.read.perm.value ?>
<?= html.cfe_unpack(view) ?>
