<? local viewtable, viewlibrary, pageinfo, session = ... ?>
Status: 200 OK
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="<?= viewtable.label ?>"

<?= viewtable.value ?>
