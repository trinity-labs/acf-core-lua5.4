module(..., package.seeall)

-- Load libraries
require("fs")
require("processinfo")

function getenabled(processname)
	local result = cfe({ label = "Program status" })
	local t = processinfo.pidof(processname)
	if (t) and (#t > 0) then
		result.value = "Enabled"
	else
		result.value = "Disabled"
	end
	return result
end

function startstop_service(initname, action)
	-- action is validated in daemoncontrol
	local cmdmessage,cmderror = processinfo.daemoncontrol(initname, action)
	return cfe({ value=cmdmessage or "", errtxt=cmderror, label="Start/Stop result" })
end

function getstatus(processname, packagename, label, initname)
	local status = {}
	
	local value, errtxt = processinfo.package_version(packagename)
	status.version = cfe({
		label="Program version",
		value=value,
		errtxt=errtxt,
		})

	status.status = getenabled(processname)

	local autostart_sequence, autostart_errtxt = processinfo.process_botsequence(initname or processname)
	status.autostart = cfe({
		label="Autostart sequence",
		value=autostart_sequence,
		errtxt=autostart_errtxt,
		})
	
	return cfe({ type="group", value=status, label=label })
end

function getfiledetails(file, validatefunction)
	local filename = cfe({ value=file, label="File name" })
	local filecontent = cfe({ type="longtext", label="File content" })
	local filesize = cfe({ value="0", label="File size" })
	local mtime = cfe({ value="---", label="File date" })
	if fs.is_file(file) then
		local filedetails = fs.stat(file)
		filecontent.value = fs.read_file(file)
		filesize.value = filedetails.size
		mtime.value = filedetails.mtime
	else
		filename.errtxt = "File not found"
	end
	local filedetails = cfe({ type="group", value={filename=filename, filecontent=filecontent, filesize=filesize, mtime=mtime}, label="Config file details" })
	local success = true
	if validatefunction then
		success, filedetails = validatefunction(filedetails)
	end
	return filedetails
end

function setfiledetails(filedetails, validatefunction)
	filedetails.value.filecontent.value = string.gsub(format.dostounix(filedetails.value.filecontent.value), "\n+$", "")
	local success = true
	if validatefunction then
		success, filedetails = validatefunction(filedetails)
	end
	if success then
		fs.write_file(filedetails.value.filename.value, filedetails.value.filecontent.value)
		filedetails = getfiledetails(filedetails.value.filename.value)
	else
		filedetails.errtxt = "Failed to set file"
	end

	return filedetails
end

function validateselect(select)
	for i,option in ipairs(select.option) do
	 	if option == select.value then
			return true
		end
	end
	select.errtxt = "Invalid selection"
	return false
end

function validatemulti(multi)
	local reverseoption = {}
	for i,option in ipairs(multi.option) do
		reverseoption[option] = i
	end
	for i,value in ipairs(multi.value) do
		if not reverseoption[value] then
			multi.errtxt = "Invalid selection"
			return false
		end
	end
	return true
end


function write_file_with_audit (self, path, str)
	local pre = ""
	local post = ""
	local tmpfile = (self.conf.sessiondir or "/tmp/") .. 
		(self.sessiondata.userinfo.userid or "unknown") .. "-" ..
		 os.time() .. ".tmp"
	
	if type(self.conf) == "table" then
		-- we make temporary globals for expand_bash_syntax_vars
		local a,b,c = TEMPFILE,CONFFILE,_G.self
		TEMPFILE=tmpfile
		CONFFILE=path
		_G.self=self

		pre = format.expand_bash_syntax_vars(self.conf.audit_precommit or "" )
		post = format.expand_bash_syntax_vars(self.conf.audit_postcommit or "")
		TEMPFILE,CONFFILE,_G.self = a,b,c
	end
	
	fs.write_file(tmpfile,str)
	
	if #pre then
		os.execute(pre)
	end
	
	os.rename (tmpfile, path)
	
	if #post then
		os.execute(post)
	end
	return
end
