<? local view= ... ?> 
<h1>User Status </h1>
<p> Below is your current Session id <p>
<?= view.stats.sessid.value ?>
<p>User account and role information may appear below.</p>
<pre><?= view.stats.checkme.value ?></pre>
