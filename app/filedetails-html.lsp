<? local form, viewlibrary, page_info = ... ?>
<? require("viewfunctions") ?>

<? if form.type == "form" then ?>
<H1>Configuration</H1>
<H2>Expert Configuration</H2>
<? else ?>
<H1>View File</H1>
<? end ?>
<H3>File Details</H3>
<DL>
<? 
displayitem(form.value.filename)
displayitem(form.value.filesize)
displayitem(form.value.mtime)
?>
</DL>

<H3>File Content</H3>
<? if form.descr then ?><P CLASS='descr'><?= string.gsub(form.descr, "\n", "<BR>") ?></P><? end ?>
<? if form.errtxt then ?><P CLASS='error'><?= string.gsub(form.errtxt, "\n", "<BR>") ?></P><? end ?>
<form action="<?= page_info.script .. page_info.prefix .. page_info.controller .. "/" .. page_info.action ?>" method="POST">
<textarea name="filecontent">
<?= form.value.filecontent.value ?>
</textarea>
<? if form.value.filecontent.errtxt then ?><P CLASS='error'><?= string.gsub(form.value.filecontent.errtxt, "\n", "<BR>") ?></P><? end ?>

<? if form.type == "form" then ?>
<DL><DT></DT><DD><input class="submit" type="submit" name="<?= form.option ?>" value="<?= form.option ?>"></DD></DL>
<? end ?>
</form>
