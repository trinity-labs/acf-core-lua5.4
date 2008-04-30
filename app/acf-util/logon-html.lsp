<? local form = ... ?>
<? require("viewfunctions") ?>
<? --[[
       io.write(html.cfe_unpack(form))
   --]] ?>

<? if form.errtxt then ?>
<h1>Command Result</h1>
<p class='error'> <?= form.errtxt ?></p>
<? end ?>

<h1><?= form.label ?></h1>
<?
   form.action = "logon"
   form.submit = "Logon"
   form.value.password.type = "password"
   local order = { "userid", "password" }
   displayform(form, order)
?>
