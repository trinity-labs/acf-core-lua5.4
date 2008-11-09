-- This file is loaded into self.conf.app_hooks as lua source code
-- The purpose is to add user-specified hooks into the acf code

-- or functions.  For functions, three variables are passed:
-- self, CONFFILE, and TEMPFILE

--[[ This is commented out example code.. 

tinydns={
  audit_precommit = function (self, CONFFILE, TEMPFILE)
  	os.execute("echo this is tinydns's precommit command >> /var/log/acf.log")
	end
  audit_postcommit = "echo 'this is the tinydns postcommit command.' >>/var/log/acf.log "
}
]]--
