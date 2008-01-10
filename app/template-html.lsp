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

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title><?= pageinfo.hostname .. " - " .. pageinfo.controller .. "->" .. pageinfo.action ?></title>
<link rel="stylesheet" type="text/css" href="/static/reset.css">
<link rel="stylesheet" type="text/css" href="<?= "/"..pageinfo.skin.."/"..pageinfo.skin..".css" ?>">
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
			<p><?= pageinfo.hostname or "unknown hostname" ?></p>
			<div class="tailer"></div>
		</div>
		<span class="mute">
			<p>[ logon link will go here ] | 
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
			 -- FIXME: This needs to go in a library function somewhere (menubuilder?)
			io.write ( "<ul>\n\t\t\t\t<li>Log in/out\n\t\t\t\t\t<ul>\n")
			local ctlr = pageinfo.script .. "/acf-util/logon/"
			if session.id == nil then 
			   io.write ( string.format("\t\t\t\t\t\t<li><a href=\"%s\">Log in</a></li>\n", ctlr .. "logon" ) )
			else
			   sess = session.name or "unknown"
			   io.write ( string.format("\t\t\t\t\t\t<li><a href=\"%s\">Log out as '" .. sess .. "'</a></li>\n", ctlr .. "logout" ) )
			end

			  local cat, group
			  local class
			  for k,v in ipairs(mainmenu) do
				if v.cat ~= cat then
					cat = v.cat
					if (cat ~= "") then		-- Filter out empty categories
						io.write (string.format("\t\t\t\t\t</ul>\n\t\t\t\t</li>\n\t\t\t\t<li>%s\n\t\t\t\t\t<ul>\n", cat))	--start row
					end
					group = ""
				end
				if v.group ~= group then
					group = v.group
					if      pageinfo.prefix  == v.prefix .. "/"  and 
						pageinfo.controller == v.controller and pageinfo.action == v.action then
						class="class='selected'"
					else
						class=""
					end
					io.write (string.format("\t\t\t\t\t\t<li %s><a href=\"%s%s/%s/%s\">%s</a></li>\n", 
						class,ENV.SCRIPT_NAME,v.prefix, v.controller, v.action, v.group ))
				end
			  end ?>
			</ul></li>
			</ul>

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
			<? for k,v in pairs(submenu)  do
				if v == pageinfo.action then
					class="class='selected'"
				else
					class=""
				end
				io.write (string.format('\t\t\t<a %s href="%s">%s</a>\n',class,v,v ))
			end
			?>

			<div class="tailer">
			</div>
		</div> <!-- subnav -->

<div id="content">
	<div class="leader">
	</div>

	<? local func = haserl.loadfile(pageinfo.viewfile) ?>
	<? func (viewtable) ?>

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
