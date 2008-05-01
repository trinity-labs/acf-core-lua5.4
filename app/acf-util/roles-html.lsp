<? local view= ... ?> 
<? --[[
	io.write(html.cfe_unpack(view))
--]] ?>

<? ---[[ ?>
<? if view.value.userid then ?>
	<H1>Roles/Permission list for <?= view.value.userid.value ?>:</H1>
<? elseif view.value.role then ?>
	<H1>Permission list for <?= view.value.role.value ?>:</H1>
<? else ?>
	<H1>Complete permission list:</H1>
<? end ?>

<? if view.value.roles then ?>
	<H2><?= view.value.userid.value ?> is valid in these roles</H2>
	<? for a,b in pairs(view.value.roles.value) do
		print("<li>",b,"</li>")
	end ?>
<? end ?>
<? --]] ?>

<? ---[[ ?>
<? if view.value.permissions then ?>
	<? if view.value.userid then ?>
		<H2><?= view.value.userid.value ?>'s full permissions are</H2>
	<? elseif view.value.role then ?>
		<H2><?= view.value.role.value ?>'s full permissions are</H2>
	<? end ?>
	<? for x,cont in pairs(view.value.permissions.value) do
		print("<b>",x,"</b>")
		for y,act in pairs(cont) do
			print(y)
		end
		print("<br>")
	end ?>
<? end ?>
<? --]] ?>
