<? local view= ... ?> 
<? --[[
	io.write(html.cfe_unpack(view))
--]] ?>

<? ---[[ ?>
<H1>ROLES</H1>

<? if view.value.cmdresult then ?>
<H2>Command Result</H2>
<dl><?= view.value.cmdresult.value ?></dl>
<? end ?>

<H2>Create new role</H2>
<form action="newrole" method="POST">
<dl><dt><input class="submit" type="submit" value="New Role"></dt></dl>
</form>

<H2>Existing roles</H2>
<? if view.value.default_roles then ?>
	<dl>
	<? for x,role in pairs(view.value.default_roles.value) do ?>
		<dt><img src='/static/tango/16x16/categories/applications-system.png' height='16' width='16'> <?= role ?></dt>
		<dd>
		[<a href='viewroleperms?role=<?= role ?>'>View this role</a>]
		</dd>
	<? end ?>
	</dl>
<? end ?>
<? if view.value.defined_roles then ?>
	<dl>
	<? table.sort(view.value.defined_roles.value) ?>
	<? for x,role in pairs(view.value.defined_roles.value) do ?>
		<dt><img src='/static/tango/16x16/apps/system-users.png' height='16' width='16'> <?= role ?></dt>
		<dd>
		[<a href='viewroleperms?role=<?= role ?>'>View this role</a>]
		[<a href='editrole?role=<?= role ?>'>Edit this role</a>]
		[<a href='deleterole?role=<?= role ?>'>Delete this role</a>]
		</dd>
	<? end ?>
	</dl>
<? end ?>
<? --]] ?>
