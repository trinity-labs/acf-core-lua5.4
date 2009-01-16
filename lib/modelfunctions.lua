module(..., package.seeall)

-- Load libraries
require("fs")
require("format")
require("processinfo")

function getenabled(processname)
	local result = cfe({ label = "Program status", name=processname })
	local t = processinfo.pidof(processname)
	if (t) and (#t > 0) then
		result.value = "Running"
	else
		result.value = "Stopped"
	end
	return result
end

function startstop_service(servicename, action)
	-- action is validated in daemoncontrol
	local cmdmessage,cmderror = processinfo.daemoncontrol(servicename, action)
	return cfe({ value=cmdmessage or "", errtxt=cmderror, label="Start/Stop result" })
end

function getstatus(processname, packagename, label, servicename)
	local status = {}
	
	local value, errtxt = processinfo.package_version(packagename)
	status.version = cfe({
		label="Program version",
		value=value,
		errtxt=errtxt,
		name=packagename
		})

	status.status = getenabled(processname)

	local autostart_sequence, autostart_errtxt = processinfo.process_startupsequence(servicename or processname)
	status.autostart = cfe({
		label="Autostart sequence",
		value=autostart_sequence,
		errtxt=autostart_errtxt,
		name=servicename or processname
		})
	
	return cfe({ type="group", value=status, label=label })
end

function getfiledetails(file, validatefilename, validatefiledetails)
	local filename = cfe({ value=file or "", label="File name" })
	local filecontent = cfe({ type="longtext", label="File content" })
	local filesize = cfe({ value="0", label="File size" })
	local mtime = cfe({ value="---", label="File date" })
	local filedetails = cfe({ type="group", value={filename=filename, filecontent=filecontent, filesize=filesize, mtime=mtime}, label="Config file details" })
	local success = true
	if type(validatefilename) == "function" then
		success = validatefilename(filedetails.value.filename.value)
		if not success then
			filedetails.value.filename.errtxt = "Invalid File"
		end
	elseif type(validatefilename) == "table" then
		success = false
		filedetails.value.filename.errtxt = "Invalid File"
		for i,f in ipairs(validatefilename) do	
			if f == filedetails.value.filename.value then
				success = true
				filedetails.value.filename.errtxt = nil
			end
		end
	end
	if success then
		if fs.is_file(file) then
			local filedetails = fs.stat(file)
			filecontent.value = fs.read_file(file) or ""
			filesize.value = filedetails.size
			mtime.value = filedetails.mtime
		else
			filename.errtxt = "File not found"
		end
		if validatefiledetails then
			success, filedetails = validatefiledetails(filedetails)
		end
	end
	return filedetails
end

function setfiledetails(filedetails, validatefilename, validatefiledetails)
	filedetails.value.filecontent.value = string.gsub(format.dostounix(filedetails.value.filecontent.value), "\n+$", "")
	local success = true
	if type(validatefilename) == "function" then
		success = validatefilename(filedetails.value.filename.value)
		if not success then
			filedetails.value.filename.errtxt = "Invalid File"
		end
	elseif type(validatefilename) == "table" then
		success = false
		filedetails.value.filename.errtxt = "Invalid File"
		for i,f in ipairs(validatefilename) do	
			if f == filedetails.value.filename.value then
				success = true
				filedetails.value.filename.errtxt = nil
			end
		end
	end
	if success and type(validatefiledetails) == "function" then
		success, filedetails = validatefiledetails(filedetails)
	end
	if success then
		--fs.write_file(filedetails.value.filename.value, filedetails.value.filecontent.value)
		write_file_with_audit(filedetails.value.filename.value, filedetails.value.filecontent.value)
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
	-- if there are only two parameters, assume self was omitted
	if not str then
		str = path
		path = self
		self = nil
	end
	-- attempt to find self
	if not self then
		if SELF and #SELF > 0 then
			self = SELF[#SELF]
		elseif APP then
			self = APP
		end
	end

	if self then
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

			pre = self.conf.audit_precommit or ""
			post = self.conf.audit_postcommit or ""

			local m = self.conf.app_hooks[self.conf.controller] or {}
			if m.audit_precommit then pre = m.audit_precommit end
			if m.audit_postcommit then post = m.audit_postcommit end
			m=nil

			if (type(pre) == "string") then 
				pre = format.expand_bash_syntax_vars(pre)
			end
			if type (post) == "string" then
				post = format.expand_bash_syntax_vars(post)
			end
			TEMPFILE,CONFFILE,_G.self = a,b,c
		end

		fs.write_file(tmpfile,str)

		if (type(pre) == "string" and #pre) then
			os.execute(pre)
		elseif (type(pre) == "function") then
			pre(self, path, tmpfile)
		end

		if fs.dirname(path) and not posix.stat(fs.dirname(path)) then fs.create_directory(fs.dirname(path)) end
		os.rename (tmpfile, path)

		if (type(post) == "string" and #post) then
			os.execute(post)
		elseif (type(post) == "function") then
			post(self, path, tmpfile)
		end
	else
		fs.write_file(path,str)
	end

	return
end
