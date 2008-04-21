<? local view= ... ?> 
<? --[[
	io.write(html.cfe_unpack(view))
--]] ?>

<? ---[[ ?>
<H1>Roles/Permission list for <?= view.userid ?>:</H1>

<? if view.roles then ?>
	<H2>You are valid in these roles</H2>
	<? for a,b in pairs(view.roles) do
		print("<li>",b,"</li>")
	end ?>
<? end ?>
<? --]] ?>

<? ---[[ ?>
<? if view.permissions then ?>
	<H2>Your full permissions are</H2>
	<? for x,cont in pairs(view.permissions) do
		print("<b>",x,"</b>")
		for y,act in pairs(cont) do
			print(y)
		end
		print("<br>")
	end ?>
<? end ?>
<? --]] ?>
