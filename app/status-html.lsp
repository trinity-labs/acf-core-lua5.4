<? local data = ... 
require("viewfunctions")
?>

<H1>System Info</H1>
<DL>
<?
displayitem(data.value.status)
displayitem(data.value.version)
displayitem(data.value.autostart)
?>
</DL>
