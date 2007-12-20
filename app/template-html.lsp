<? local pageinfo , mainmenu, submenu, viewtable, session = ... 
   html=require("html") ?>
Status: 200 OK
Content-Type: text/html
<? if (session.id) then 
	io.write( html.cookie.set("sessionid", session.id) ) 
  else
	io.write (html.cookie.unset("sessionid"))
  end
?>

<!DOCTYPE HTML PUBLIC "-//W3C//DDD HTML 4.01 Transitional//EN">
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title><?= pageinfo.hostname .. " - " .. pageinfo.controller .. "->" .. pageinfo.action ?></title>
<link rel="stylesheet" type="text/css" 
	href=<?= "/"..pageinfo.skin.."/"..pageinfo.skin..".css" ?> ">
</head>
<body>

<div id="page">
	<div id="header">
		<div id="logo">
			<?= pageinfo.hostname ?>
		</div>	<? --logo ?>
		<div id="version">
			<?= pageinfo.alpineversion ?>
		</div>	<? --version ?>
		<ul id="metanav">
			<? local class="" ?>
			<? for k,v in pairs(submenu)  do
				if v == pageinfo.action then
					class="current"
				else
					class="noselect"
				end
				io.write (string.format('<li class="%s"><a href="%s">%s</a></li>\n',class,v, v ))

			end
			?>
		</ul>
	</div>	<? --header ?>


	<div id="content">
		<div id="nav"><ul>
			<? 
			 -- FIXME: This needs to go in a library function somewhere (menubuilder?)
			io.write ( "<li class=category>Log in/out</li>\n")
			local ctlr = pageinfo.script .. "/acf-util/logon/"
			if session.id == nil then 
			   io.write ( string.format("<li class=menuitem><a href=\"%s\">Log in</a></li>", ctlr .. "logon" ) )
			else
			   sess = session.name or "unknown"
			   io.write ( string.format("<li class=menuitem><a href=\"%s\">Log out as '" .. sess .. "'</a></li>", ctlr .. "logout" ) )
			end

			  local cat, group
			  local class
			  for k,v in ipairs(mainmenu) do
				if v.cat ~= cat then
					cat = v.cat
					io.write (string.format("<li class=category>%s</li>\n", cat))	--start row
					group = ""
				end
				if v.group ~= group then
					group = v.group
					if      pageinfo.prefix  == v.prefix .. "/"  and 
						pageinfo.controller == v.controller then
						class="current"
					else
						class="menuitem"
					end
					io.write (string.format("<li class=\"%s\"><a href=\"%s%s/%s/%s\">%s</a></li>\n", 
						class,ENV.SCRIPT_NAME,v.prefix, v.controller, v.action, v.group ))
				end
			  end ?>
		<li class="last"></li>
		</ul></div>	<? --nav ?>

		<div id="wrapper"><div id="background-wrapper">
				<? local func = haserl.loadfile(pageinfo.viewfile)
				func (viewtable) ?>
			<div id="footer">
				<center>Made with care by acf</center>
			</div>	<? --footer ?>
		</div></div>	<? --wrapper ?>
	</div>	<? --content ?>
</div>	<? --page ?>


</body>
</html>
