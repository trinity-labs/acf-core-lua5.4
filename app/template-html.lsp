<? local viewtable, viewlibrary, pageinfo, session = ... 
   html=require("html") ?>
Status: 200 OK
Content-Type: text/html
<? if (session.id) then 
	io.write( html.cookie.set("sessionid", session.id) ) 
  else
	io.write (html.cookie.unset("sessionid"))
  end
?>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<?
local hostname = ""
if viewlibrary and viewlibrary.dispatch_component then
	local result = viewlibrary.dispatch_component("alpine-baselayout/hostname/read", nil, true)
	if result and result.value then
		hostname = result.value
	end
end
?>
<title><?= hostname .. " - " .. pageinfo.controller .. "->" .. pageinfo.action ?></title>
<link rel="stylesheet" type="text/css" href="/static/reset.css">
<link rel="stylesheet" type="text/css" href="<?= "/"..pageinfo.skin.."/"..pageinfo.skin..".css" ?>">
<!--[if IE]>
<link rel="stylesheet" type="text/css" href="<?= "/"..pageinfo.skin.."/"..pageinfo.skin.."-ie.css" ?>">
<![endif]-->
</head>
<body>

<div id="page">
	<div id="header">
		<div class="leader">
			<a href="#Content" class="hide">[Skip to main content]</a>
		</div>
		<div id="logo">
			<div class="leader"></div>
			<h1>AlpineLinux</h1>
			<p><?= hostname or "unknown hostname" ?></p>
			<div class="tailer"></div>
		</div>
		<span class="mute">
			<p>
			<? local ctlr = pageinfo.script .. "/acf-util/logon/"
			
			if session.userinfo and session.userinfo.userid then
			   io.write ( string.format("\t\t\t\t\t\t<a href=\"%s\">Log out as '" .. session.userinfo.userid .. "'</a>\n", ctlr .. "logout" ) )
			else
			   io.write ( string.format("\t\t\t\t\t\t<a href=\"%s\">Log in</a>\n", ctlr .. "logon" ) )
			end ?>
			 | 
			<a href="/">home</a> | 
			<a href="http://wiki.alpinelinux.org">about</a>
			</p></span>
		<div class="tailer"></div>
	</div>	<!-- header -->

	<div id="main">
		<div class="leader">
		</div>

		<div id="nav">
			<div class="leader">
				<h3 class="hide">[Main menu]</h3>
			</div>

			<? 
			local class
			local tabs
			io.write ( "<ul>")
			for x,cat in ipairs(session.menu.cats) do
				io.write (string.format("\n\t\t\t\t<li>%s\n\t\t\t\t\t<ul>\n", cat.name))	--start row
				for y,group in ipairs(cat.groups) do
					if pageinfo.prefix == group.prefix .. '/' and pageinfo.controller == group.controller then
						class="class='selected'"
						tabs = group.tabs
					else
						class=""
					end
					io.write (string.format("\t\t\t\t\t\t<li %s><a href=\"%s%s/%s/%s\">%s</a></li>\n", 
						class,pageinfo.script,group.prefix, group.controller, group.tabs[1].action, group.name ))
				end
				io.write ( "\t\t\t\t\t</ul>" )
			  end
			io.write ( "\n\t\t\t\t</li>\n\t\t\t</ul>\n")
			?>

			<div class="tailer">
			</div>
		</div>	<!-- nav -->


		<div id="postnav">
			<div class="leader">
			</div>
			<h2><?= pageinfo.controller ?> : <?= pageinfo.action ?></h2>
			<!-- FIXME: Next row is 'dead' data! Remove 'class=hide' when done! -->
			<p class='hide'>[ welcome ] > [ login ] > [ bgp ] > [ firewall ] > [ content filter ] > [ interfaces ]</p>
			<div class="tailer">
			</div>
		</div>	<!-- postnav -->

		<a name="Content"></a>

		<div id="subnav">
			<div class="leader">
				<h3 class="hide">[Submenu]</h3>
			</div>

			<? local class="" ?>
			<? for x,tab in pairs(tabs or {})  do
				if tab.action == pageinfo.action then
					class="class='selected'"
				else
					class=""
				end
				io.write (string.format('\t\t\t<a %s href="%s">%s</a>\n',class,tab.action,tab.name ))
			end
			?>

			<div class="tailer">
			</div>
		</div> <!-- subnav -->

<div id="content">
	<div class="leader">
	</div>

	<? local func = haserl.loadfile(pageinfo.viewfile) ?>
	<? func (viewtable, viewlibrary, pageinfo, session) ?>

	<div class="tailer">
	</div>
</div>	<!-- content -->

	</div> <!-- main -->

	<div id="footer">
		<div class="leader">
		</div>
		Made with care by webconf
		<div class="tailer">
		</div>
	</div> <!-- footer -->
</div> <!-- page -->

</body>
</html>
