<? local form = ... ?>
<? require("viewfunctions") ?>
<? --[[
       io.write(html.cfe_unpack(form))
   --]] ?>

<h1><?= form.label ?></h1>
<?
   form.action = "logon"
   form.submit = "Logon"
   form.value.password.type = "password"
   local order = { "userid", "password" }
   displayform(form, order)
?>
