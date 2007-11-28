--date and time functions 

module(..., package.seeall)

require("posix")
require("format")

--global for date formating see below for more information
--Mon Nov 26 19:56:10 UTC 2007 looks like most systems use this
--print(os.date(date.format))
format = "%a %b %d %X %Z %Y"

months ={ {"January","Jan"},  
          {"February", "Feb"}, 
          {"March","Mar"}, 
          {"April", "Apr"},
	  {"May","May"},
	  {"June","Jun"},
	  {"July","Jul"},
	  {"August","Aug"},
	  {"September","Sep"},
	  {"October","Oct"},
	  {"November","Nov"},
	  {"December","Dec"}
	   }

revmonths = {["january"] = 1, ["jan"] = 1, 
	     ["february"] = 2, ["feb"] = 2,
	     ["march"] = 3, ["mar"] = 3, 
	     ["april"] = 4, ["apr"] = 4, 
	     ["may"] = 5,
	     ["june"] = 6, ["jun"] = 6,
	     ["july"] = 7, ["jul"] = 7,
	     ["august"] = 8, ["aug"] = 8,
	     ["september"] = 9, ["sep"] = 9,
	     ["october"] = 10, ["oct"] = 10,
	     ["november"] = 11, ["nov"] = 11,
	     ["december"] = 12, ["dec"] = 12 
	     }

dow = { {"Sunday","Sun"}, 
	{"Monday","Mon"},
	{"Tuesday","Tue"},
	{"Wednesday","Wed"},
	{"Thursday","Thu"},
	{"Friday","Fri"},
	{"Saturday","Sat"}
	}
	
revdow = { ["sunday"] = 1, ["sun"] = 2,
	   ["monday"] = 2, ["mon"] = 2,
	   ["tuesday"] = 3, ["tue"] = 3,
	   ["wednesday"] = 4, ["wed"] = 4,
	   ["thursday"] = 5, ["thu"] = 5,
	   ["friday"] = 6, ["fri"] = 6,
	   ["saturday"] = 7, ["sat"] =7
	   }


--os.time() will give seconds since 1970-epoch
--os.date() will give formated time strings
--os.time{year=2007,month=1,day=1,hour=2,min=1,sec=1}
--os.date(date.format,os.time())

--give me a table
--t = { {year=2007,month=1,day=2,hour=2}, {year=2006,month=1,day=5} }
--will return a table sorted by oldest <-> newest 
--to grab the largest and smallest a,b=g[1],g[table.maxn(g)]
function date_to_seconds (t)
	g = {}
	count = table.maxn(t)
	for i = 1,count do
	g[#g+1] = os.time(t[i])
	end
	table.sort(g)
	return g
end

-- the reverse of date_to_seconds. expecting a table of seconds
--format can be changed. This seems to be standard, dow,mon,dom,time,zone,year
-- seems like %z- +0000 time zone format and %Z- 3 letter timezone undocumented or new

function seconds_to_date (t)
	g = {}
	count = table.maxn(t)
	for i = 1,count do
	g[#g+1] = os.date(format,t[i])	
	end
	
	return g	
end

--Wed Nov 28 14:01:23 UTC 2007
--os.date(date.format) put into a table
--year,month,day,hour,min,sec,isdst- may need a dst table to set this automatically
function string_to_table (str)
	if str == nil then str = os.date(format) end
	g = {}
	temp = format.string_to_table("%s",str)
	month = abr_month_num(temp[2])
	g["month"] = month
	day = temp[3]
	g["day"] = day
	--may do something with this if have a tz table ??
	tz = temp[5]
	year = temp[6]
	g["year"] = year
	temp2 = format.string_to_table(":",temp[4])
 	hour = temp2[1] 
 	g["hour"] = hour
 	min = temp2[2]
 	g["min"] = min
 	sec = temp2[3]
 	g["sec"] = sec
 	return g

end


--give dates in seconds and gives the difference in years,months,days,...
--gives a table back with hour,min,month,sec,day,year to display something like
--you have 10 years, 14 hours, 10 days to renew you certificate
-- in secs - year,  day, hour,min,sec
t_time = { field_names = {"years","days","hours","minutes","seconds"},
	                   31556926,86400,3600,60,1
	                   }

function date_diff (d1, d2)
	g = {}	
	if d2 == nil then d2 = os.time() end 
	--first sum of seconds
	sum = math.abs(os.difftime(d1,d2))
	--going to go through and get it smaller with each pass through the table
	for a,b in ipairs(t_time) do
	print(sum)
	hold = math.modf(sum/b)
	g[t_time.field_names[a]] = hold
	sum = (sum - (hold*b))
	end
	
	return g
end

--give a search number and return the month name

function num_month_name (search)
	return months[search][1]
end

--give a search number and return the month abr

function num_month_name_abr (search)
	return months[search][2]
end

function name_month_num (search)
	return revmonths[string.lower(search)]
end

function abr_month_num (search)
	return revmonths[string.lower(search)]
end

function num_dow_name (search)
	return dow[search][1]
end

function num_dow_name_abr (search)
	return dow[search][2]
end

function name_dow_num (search)
	return revdow[string.lower(search)]
end

function abr_dow_num (search)
	return revdow[string.lower(search)]
end

