require ("web_elements") 

local function fwrite(fmt, ...)
	return io.write(string.format(fmt, ...))
end

local function footer(time)
	fwrite("<div id=\"footer\">\n<p>This request was processed in approximately %d seconds</p>\n</div>",time)
end

header = [[
content-type: text/html
   
<!DOCTYPE HTML PUBLIC "-//W3C//ddD HTML 4.01 Transitional//EN">
<html lang="en">

<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title>Alpine log view</title>
<link rel="stylesheet" type="text/css" href="/static/webconf.css" />
<meta http-equiv='Cache-Control' content='no-cache' />
<Meta http-equiv='Pragma' content='no-cache' />
</head>]]

-- 

print(header)
print("<body>\n<div id=\"head\">")

fwrite("<h1>%s</h1>",cf.hostinfo.alpine_hostname)

fwrite("<p><em>%s</em></p>",cf.hostinfo.alpine_release)

print("</div>")

print ('<div id="mainmenu">')
local group, cat, subcat = 
		web_elements.render_mainmenu ( menu, cf.prefix, cf.controller, cf.action )
print([[
</div>

<div id="submenu">]])
web_elements.render_submenu ( menu, group, cat, subcat )
print([[</div>

<div id="content">
<p>]])
-- get the wc and view tables
-- walk the tree
web_elements.render_table ( view )
print("</p>\n</div>")

print(footer(cf.time))
print("</body></html>")

-- /* vim: set filetype=lua : */
