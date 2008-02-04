<? local view= ... ?> 
<h1>Role Views</h1>
<p>You are valid in these role <p>
<? for a,b in pairs(view.read.value) do ?>
<li><?= b ?><br>
<? end ?>

<?= html.cfe_unpack(view) ?>
