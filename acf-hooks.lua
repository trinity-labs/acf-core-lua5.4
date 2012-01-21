--
-- This file is loaded into self.conf.app_hooks using loadfile;
-- it must be correct lua source code.
-- The current format for this file is a table for each controller,
-- and then values (or tables) under the controller.  
-- 
-- The purpose of this file is to add user-specified hooks into the
-- acf code.  
-- 
-- Currently the only use for this is a per-controller audit function
-- (this overrides the acf.conf audit_precommit / postcommit globals)
-- 
-- audit_precommit | audit_postcommit can be strings (like in acf.conf)
-- or functions.  For functions, three variables are passed:
-- self, CONFFILE, and TEMPFILE

-- Example of a general logging function
format = require("acf.format")
local precommit=function(self, conf, temp)
  	local logfile = "/var/log/acf-" .. self.conf.controller .. ".log"
	fs.write_line_file (logfile, "#---- BEGIN TRANSACTION - " .. 
		 os.date() .. "\n" .. self.sessiondata.userinfo.userid ..
		" modifed " .. conf .. " as follows:")
	 os.execute ("diff -u " .. format.escapespecialcharacters(conf) .. " " .. format.escapespecialcharacters(temp) .. " >>" .. format.escapespecialcharacters(logfile))
	 fs.write_line_file (logfile, "\n#---- END TRANSACTION -")
	end



interfaces = {
      -- note that we must define the audit command as a 
      -- new function to wrap the local func:
	audit_precommit=function(self,conf,temp)
		precommit(self, conf, temp)
	end

-- audit_postcommit = [[ echo "this is tinydns's postcommit command." >>/var/log/acf.log ]]
}

-- but after defining the audit_* commands as direct functions,
-- assining other controllers to be the same is fine... 
tinydns=interfaces

