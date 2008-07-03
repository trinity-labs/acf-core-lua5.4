<? local data, viewlibrary, page_info, session = ... ?>
<H1>Debugging</H1>
<H2>View Data:</H2>
<?= html.cfe_unpack(data) ?>
<H2>Session:</H2>
<?= html.cfe_unpack(session) ?>
<H2>Page Info:</H2>
<?= html.cfe_unpack(page_info) ?>
