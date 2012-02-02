module(..., package.seeall)

html = require("acf.html")
require("session")

local function getlabel(myitem, value)
	if myitem and (myitem.type == "select" or myitem.type == "multi") then
		for x,val in ipairs(myitem.option) do
			local v,l
			if type(val) == "string" then
				v = val
				l = val
			else
				v = val.value
				l = val.label
			end
			if v == value then
				return l
			end
		end
	end
	return tostring(value)
end

function displayitem(myitem, header_level, page_info)
	if not myitem then return end
	if myitem.type == "form" then
		header_level = header_level or 1
		io.write("<H"..tostring(header_level)..">"..html.html_escape(myitem.label).."</H"..tostring(header_level)..">")
		displayform(myitem, nil, nil, page_info, header_level)
	elseif myitem.type == "group" then
		header_level = header_level or 1
		io.write("<H"..tostring(header_level)..">"..html.html_escape(myitem.label).."</H"..tostring(header_level)..">")
		if myitem.descr then io.write('<P CLASS="descr">' .. string.gsub(html.html_escape(myitem.descr), "\n", "<BR>") .. "</P>\n") end
		if myitem.errtxt then io.write('<P CLASS="error">' .. string.gsub(html.html_escape(myitem.errtxt), "\n", "<BR>") .. "</P>\n") end
		local seqorder = {}
		local order = {}
		for name,item in pairs(myitem.value) do
			if tonumber(item.seq) then
				seqorder[#seqorder+1] = {seq=tonumber(item.seq), name=name}
			else
				order[#order+1] = name
			end
		end
		table.sort(seqorder, function(a,b) if a.seq ~= b.seq then return a.seq > b.seq else return a.name > b.name end end)
		table.sort(order)
		for i,val in ipairs(seqorder) do
			table.insert(order, 1, val.name)
		end
		for x,name in ipairs(order) do
			if myitem.value[name] then
				displayitem(myitem.value[name], tonumber(header_level)+1)
			end
		end
	elseif myitem.type ~= "hidden" then
		io.write("<DT")
		if myitem.errtxt then 
			myitem.class = "error"
			io.write(' class="error"')
		end
		io.write(">" .. html.html_escape(myitem.label) .. "</DT>\n")
		io.write("<DD>")
		io.write(string.gsub(html.html_escape(tostring(myitem.value)), "\n", "<BR>") .. "\n")
		if myitem.descr then io.write("<P CLASS='descr'>" .. string.gsub(html.html_escape(myitem.descr), "\n", "<BR>") .. "</P>\n") end
		if myitem.errtxt then io.write("<P CLASS='error'>" .. string.gsub(html.html_escape(myitem.errtxt), "\n", "<BR>") .. "</P>\n") end
		io.write("</DD>\n")
	end
end

function displayformitem(myitem, name, viewtype, header_level, group)
	if not myitem then return end
	if name then myitem.name = name end
	if group and group ~= "" then myitem.name = group.."."..myitem.name end
	if myitem.type ~= "hidden" and myitem.type ~= "group" then
		io.write("<DT")
		if myitem.errtxt then 
			myitem.class = "error"
			io.write(' class="error"')
		end
		io.write(">" .. html.html_escape(myitem.label) .. "</DT>\n")
		io.write("<DD>\n")
	end
	if (viewtype == "viewonly") then
		myitem.disabled = "true"
	end
	if myitem.type == "group" then
		header_level = header_level or 2
		io.write("<H"..tostring(header_level)..">"..html.html_escape(myitem.label).."</H"..tostring(header_level)..">")
		if myitem.descr then io.write('<P CLASS="descr">' .. string.gsub(html.html_escape(myitem.descr), "\n", "<BR>") .. "</P>\n") end
		if myitem.errtxt then io.write('<P CLASS="error">' .. string.gsub(html.html_escape(myitem.errtxt), "\n", "<BR>") .. "</P>\n") end
		displayformcontents(myitem, nil, nil, tonumber(header_level)+1, myitem.name)
	elseif myitem.type == "multi" then
		-- FIXME multiple select doesn't work in haserl, so use series of checkboxes
		--myitem.type = "select"
		--myitem.multiple = "true"
		myitem.class = nil
		local tempname = myitem.name
		local tempval = myitem.value or {}
		local reverseval = {}
		for x,val in ipairs(tempval) do
			reverseval[val] = x
		end
		local reverseopt = {}
		for x,val in ipairs(myitem.option) do
			local v,l
			if type(val) == "string" then
				v = val
				l = val
			else
				v = val.value
				l = val.label
			end
			reverseopt[v] = x
			myitem.value = v
			myitem.checked = reverseval[v]
			myitem.name = tempname .. "." .. x
			io.write(html.form.checkbox(myitem) .. html.html_escape(l) .. "<br>\n")
		end
		-- Check for values not in options
		if myitem.errtxt then
			myitem.class = "error"
			io.write('<p class="error">\n')
		end
		for x,val in ipairs(tempval) do
			if not reverseopt[val] then
				myitem.value = val
				myitem.checked = true
				io.write(html.form.checkbox(myitem) .. html.html_escape(val) .. "<br>\n")
			end
		end
		if myitem.errtxt then
			io.write('</p>\n')
		end
		myitem.name = tempname
		myitem.value = tempval
	elseif myitem.type == "boolean" then
		local tempval = myitem.value
		if (myitem.value == true) then myitem.checked = "" end
		myitem.value = "true"
		io.write(html.form.checkbox(myitem) .. "\n")
		myitem.value = tempval
	elseif myitem.type == "list" then
		local tempval = myitem.value
		myitem.value = table.concat(myitem.value, "\n")
		io.write(html.form.longtext(myitem) .. "\n")
		myitem.value = tempval
	else
		io.write((html.form[myitem.type](myitem) or "") .. "\n")
	end
	if myitem.type ~= "hidden" and myitem.type ~= "group" then
		if myitem.descr then io.write('<P CLASS="descr">' .. string.gsub(html.html_escape(myitem.descr), "\n", "<BR>") .. "</P>\n") end
		if myitem.default then io.write('<P CLASS="descr">Default:' .. string.gsub(html.html_escape(getlabel(myitem, myitem.default)), "\n", "<BR>") .. "</P>\n") end
		if myitem.errtxt then io.write('<P CLASS="error">' .. string.gsub(html.html_escape(myitem.errtxt), "\n", "<BR>") .. "</P>\n") end
		io.write("</DD>\n")
	end
end

function displayformstart(myform, page_info)
	if not myform then return end
	if not myform.action and page_info then
		myform.action = page_info.script .. page_info.prefix .. page_info.controller .. "/" .. page_info.action
	end
	io.write('<DL>\n')
	if myform.descr then io.write('<P CLASS="descr">' .. string.gsub(html.html_escape(myform.descr), "\n", "<BR>") .. "</P>\n") end
	if myform.errtxt then io.write('<P CLASS="error">' .. string.gsub(html.html_escape(myform.errtxt), "\n", "<BR>") .. "</P>\n") end
	io.write('<form action="' .. html.html_escape(myform.action) .. '" ')
	if myform.enctype and myform.enctype ~= "" then
		io.write('enctype="'..html.html_escape(myform.enctype)..'" ')
	end
	io.write('method="POST">\n')
	if myform.value.redir then
		displayformitem(myform.value.redir, "redir")
	end
end

function displayformcontents(myform, order, finishingorder, header_level, group)
	if not myform then return end
	if not order and not finishingorder then
		tmporder = {}
		for name,item in pairs(myform.value) do
			if tonumber(item.seq) then
				tmporder[#tmporder+1] = {seq=tonumber(item.seq), name=name}
			end
		end
		if #tmporder>0 then
			table.sort(tmporder, function(a,b) if a.seq ~= b.seq then return a.seq < b.seq else return a.name < b.name end end)
			order = {}
			for i,val in ipairs(tmporder) do
				order[#order+1] = val.name
			end
		end
	end
	local reverseorder= {["redir"]=0}
	if order then
		for x,name in ipairs(order) do
			reverseorder[name] = x
			if myform.value[name] then
				myform.value[name].name = name
				displayformitem(myform.value[name], nil, nil, header_level, group)
			end
		end
	end
	local reversefinishingorder = {}
	if finishingorder then
		for x,name in ipairs(finishingorder) do
			reversefinishingorder[name] = x
		end
	end
	for name,item in pairs(myform.value) do
		if nil == reverseorder[name] and nil == reversefinishingorder[name] then
			item.name = name
			displayformitem(item, nil, nil, header_level, group)
		end
	end
	if finishingorder then
		for x,name in ipairs(finishingorder) do
			if myform.value[name] then
				myform.value[name].name = name
				displayformitem(myform.value[name], nil, nil, header_level, group)
			end
		end
	end
end

function displayformend(myform)
	if not myform then return end
	io.write('<DT></DT><DD><input class="submit" type="submit" name="' .. html.html_escape(myform.option) .. '" value="' .. html.html_escape(myform.submit or myform.option) .. '"></DD>\n')
	io.write('</FORM>')
	io.write('</DL>\n')
end

function displayform(myform, order, finishingorder, page_info, header_level)
	if not myform then return end
	displayformstart(myform, page_info)
	displayformcontents(myform, order, finishingorder, header_level)
	displayformend(myform)
end

function displaycommandresults(commands, session, preserveerrors)
	local cmdresult = {}
	for i,cmd in ipairs(commands) do
		if session[cmd.."result"] then
			cmdresult[#cmdresult + 1] = session[cmd.."result"]
			if not preserveerrors or not session[cmd.."result"].errtxt then
				session[cmd.."result"] = nil
			end
		end
	end
	if #cmdresult > 0 then
		io.write("<H1>Command Result</H1>\n<DL>\n")
		for i,result in ipairs(cmdresult) do
			if type(result.value) == "string" and result.value ~= "" then io.write(string.gsub(html.html_escape(result.value), "\n", "<BR>") .. "\n") end
			if result.descr then io.write('<P CLASS="descr">' .. string.gsub(html.html_escape(result.descr), "\n", "<BR>") .. "</P>\n") end
			if result.errtxt then io.write('<P CLASS="error">' .. string.gsub(html.html_escape(result.errtxt), "\n", "<BR>") .. "</P>\n") end
		end
		io.write("</DL>\n")
	end
end

-- Divide up data into pages of size pagesize
-- clientdata can be a page number or a table where clientdata.page is the page number
function paginate(data, clientdata, pagesize)
	local subset = data
	local page_data = { numpages=1, page=1, pagesize=pagesize, num=#data }
	if #data > pagesize then
		page_data.numpages = math.floor((#data + pagesize -1)/pagesize)
		if clientdata and clientdata.page and tonumber(clientdata.page) then
			page_data.page = tonumber(clientdata.page)
		elseif clientdata and tonumber(clientdata) then
			page_data.page = tonumber(clientdata)
		end
		if page_data.page > page_data.numpages then
			page_data.page = page_data.numpages
		elseif page_data.page < 0 then
			page_data.page = 0
		end
		if page_data.page > 0 then
			subset = {}
			for i=((page_data.page-1)*pagesize)+1, page_data.page*pagesize do
				table.insert(subset, data[i])
			end
		end
	end
	return subset, page_data
end

function displaypagination(page_data, page_info)
	local min, max
	if page_data.page == 0 then
		min = 1
		max = page_data.num
	else
		min = math.min(((page_data.page-1)*page_data.pagesize)+1, page_data.num)
		max = math.min(page_data.page*page_data.pagesize, page_data.num)
	end
	if min == max then
		io.write("Record "..min.." of "..page_data.num.."\n")
	else
		io.write("Records "..min.."-"..max.." of "..page_data.num.."\n")
	end

	if page_data.numpages > 1 then
		-- Pre-determine the links for each page
		local link = page_info.script .. page_info.orig_action .. "?"
		local clientdata = {}
		for name,val in pairs(page_info.clientdata) do
			if name ~= "sessionid" and name ~= "page" then
				clientdata[#clientdata + 1] = name.."="..val
			end
		end
		if #clientdata > 0 then
			link = link .. table.concat(clientdata, "&") .. "&"
		end
		link = link.."page="

		function pagelink(page)
			io.write(html.link{value=link..page, label=page}.."\n")
		end

		-- Print out < 1 n-50 n-25 n-10 n-2 n-1 n n+1 n+2 n+10 n+25 n+50 numpages >
		io.write('<div align="right">Pages:')
		local p = page_data.page
		if p > 1 then
			io.write("<a href="..link..(p-1).."><img SRC='"..html.html_escape(page_info.staticdir).."/tango/16x16/actions/go-previous.png' HEIGHT='16' WIDTH='16'></a>\n")
		end
		if p ~= 1 then
			pagelink(1)
		end
		local links = {(p-3)-(p-3)%10, p-2, p-1, p, p+1, p+2, (p+12)-(p+12)%10}
		table.insert(links, 1, links[1]-1-(links[1]-1)%25)
		table.insert(links, 1, links[1]-1-(links[1]-1)%50)
		table.insert(links, links[#links]+25-links[#links]%25)
		table.insert(links, links[#links]+50-links[#links]%50)
		for i,num in ipairs(links) do
			if num==p and p~=0 then
				io.write(p.."\n")
			elseif num>1 and num<page_data.numpages then
				pagelink(num)
			end
		end
		if p<page_data.numpages then
			pagelink(page_data.numpages)
			if p~= 0 then
				io.write("<a href="..link..(p+1).."><img SRC='"..html.html_escape(page_info.staticdir).."/tango/16x16/actions/go-next.png' HEIGHT='16' WIDTH='16'></a>\n")
			end
		end
		if p~=0 then
			io.write(html.link{value=link.."0", label="all"}.."\n")
		end
		io.write("</div>")
	end
end

-- give a cfe and get back a string of what is inside
-- great for troubleshooting and seeing what is really being passed to the view
function cfe_unpack ( a )
	if type(a) == "table" then
		value = session.serialize("cfe", a)
		value = "<pre>" .. html.html_escape(value) .. "</pre>"
		return value
	end
end
