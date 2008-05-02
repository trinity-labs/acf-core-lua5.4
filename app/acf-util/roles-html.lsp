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
	<? local controllers = {}
	   -- It's nice to have it in alphabetical order
	   for cont in pairs(view.value.permissions.value) do
		controllers[#controllers + 1] = cont
	   end
	   table.sort(controllers)
	   for x,cont in ipairs(controllers) do
		print("<b>",cont,"</b>")
		-- Again, alphabetical order
		local actions = {}
		for act in pairs(view.value.permissions.value[cont]) do
			actions[#actions + 1] = act
		end
		table.sort(actions)
		for y,act in pairs(actions) do
			print(act)
		end
		print("<br>")
	end ?>
<? end ?>
<? --]] ?>
