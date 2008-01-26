<? local view= ... ?> 
<h1>User Status </h1>
<p> Below is your current Session id <p>
<?= view.stats.sessid.value ?>
<p>You are currently known to the system as <?= view.stats.checkme.value ?>.</p>
