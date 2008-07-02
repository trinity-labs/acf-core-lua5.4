module(..., package.seeall)

-- Load libraries
require("procps")
require("daemoncontrol")
require("processinfo")

local function process_status_text(procname)
	local t = procps.pidof(procname)
	if (t) and (#t > 0) then
		return "Enabled"
	else
		return "Disabled"
	end
end

function startstop_service(processname, action)
	-- action is validated in daemoncontrol
	local cmdresult,cmdmessage,cmderror,cmdaction = daemoncontrol.daemoncontrol(processname, action)
	return cfe({ type="boolean", value=cmdresult, descr=cmdmessage, errtxt=cmderror, label="Start/Stop result" })
end

function getstatus(processname, packagename, label)
	local status = {}
	
	local value, errtxt = processinfo.package_version(packagename)
	status.version = cfe({
		label="Program version",
		value=value,
		errtxt=errtxt,
		})

	status.status = cfe({
		label="Program status",
		value=process_status_text(processname),
		})

	local autostart_sequence, autostart_errtxt = processinfo.process_botsequence(processname)
	status.autostart = cfe({
		label="Autostart sequence",
		value=autostart_sequence,
		errtxt=autostart_errtxt,
		})
	
	return cfe({ type="group", value=status, label=label })
end

function getfiledetails(file)
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
	return cfe({ type="group", value={filename=filename, filecontent=filecontent, filesize=filesize, mtime=mtime}, label="Config file details" })
end
