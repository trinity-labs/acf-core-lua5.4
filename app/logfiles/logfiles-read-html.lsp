<? local view = ... ?>
<html>
<body>
<h1>Logfile</h1>
<dt><?= view.logfile.name ?></dt>
<dd><textarea name="<?= view.logfile.name ?>"><?= view.logfile.value ?></textarea></dd>
</body>
</html> 
