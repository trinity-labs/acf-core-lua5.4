--date and time functions 


module(..., package.seeall)

require("posix")

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
-- i am sure there is a better way to do this than a new table

revmonths = {["January"] = 1, ["Jan"] = 1, 
	     ["February"] = 2, ["Feb"] = 2,
	     ["March"] = 3, ["Mar"] = 3, 
	     ["April"] = 4, ["Apr"] = 4, 
	     ["May"] = 5,
	     ["June"] = 6, ["Jun"] = 6,
	     ["July"] = 7, ["Jul"] = 7,
	     ["August"] = 8, ["Aug"] = 8,
	     ["September"] = 9, ["Sep"] = 9,
	     ["October"] = 10, ["Oct"] = 10,
	     ["November"] = 11, ["Nov"] = 11,
	     ["December"] = 12, ["Dec"] = 12 
	     }
	     	
--give a search number and return the month name

function num_month_name (search)
	return months[search][1]
end

--give a search number and return the month abr

function num_month_name_abr (search)
	return months[search][2]
end

function name_month_num (search)
	return revmonths[search]
end

function abr_month_num (search)
	return revmonths[search]
end
