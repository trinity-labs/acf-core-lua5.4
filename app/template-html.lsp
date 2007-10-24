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
<link rel="stylesheet" type="text/css" href="/static/webconf.css">
</head>
<body>

<div id=head>
<p>Host: <em><?= pageinfo.hostname ?></em></p>
</div>

<div id=logo>
</div>

<div id="mainmenu">
<? 
 -- FIXME: This needs to go in a library function somewhere (menubuilder?)

local ctlr = pageinfo.script .. "/acf-util/logon/"
if session.id == nil then 
   io.write ( html.link( { label = "Log in", value = ctlr .. "logon" } ) )
else
  io.write (html.link( { label = "Logout as " .. ( session.name or "unkown") , value = ctlr .. "logout" } ) )
end

  local cat, group
  local liston=false
  local selected
  for k,v in ipairs(mainmenu) do
	if v.cat ~= cat then
		if liston == true then 
			io.write ("</ul>\n")
			liston=false
		end
		cat = v.cat
		io.write (string.format("<h3>%s</h3>\n", cat))
		group = ""
	end
	if v.group ~= group then
		group = v.group
		if liston == false then
			io.write ("<ul>")
			liston=true
		end
		if      pageinfo.prefix  == v.prefix .. "/"  and 
			pageinfo.controller == v.controller then
				selected=" id=\"selected\""
			else
				selected=""
		end
		io.write (string.format("<li%s><a href=\"%s%s/%s/%s\">%s</a></li>\n", 
				selected, ENV.SCRIPT_NAME,v.prefix, v.controller, v.action, v.group))
	end
  end
?>
</ul>
</div>

<div id="submenu">
<h2><?= pageinfo.prefix ?> > <?= pageinfo.controller .. " > " .. pageinfo.action ?></h2>
<ul>
<? for k,v in pairs(submenu)  do
	if v == pageinfo.action then
		io.write (string.format('<li id="selected">%s</li>\n',
			v, v ))
    	else
		io.write (string.format('<li><a href="%s">%s</a></li>\n',
			v, v ))
    	end
  end
?>
</ul>
</div>



<div id="content">
<? local func = haserl.loadfile(pageinfo.viewfile)
   func (viewtable) ?>
      <div id="footer">
      <p><center>Made with care by acf</center></p>
      </div>
</div>



</body>
</html>
