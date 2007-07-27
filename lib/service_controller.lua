local function build_status(model, name)
    return {
	type = "form",
	method = "post",
	action = cf.uri .. "/chrun",
	value = {
	    {
		type = "formtext",
		name = "status",
		label = "Status: <B>" .. name .. "</B>",
		value = model.status(name)
	    },
	    {
		type = "hidden",
		name = "service",
		value = name
	    },
	    {
		type = "submit",
		name = "cmd",
		label = "Running controls",
		value = { "Start", "Stop", "Restart" }
	    },
	}
    }
end

local function build_note(model, name)
    return {
	type = "form",
	method = "post",
	action = cf.uri .. "/note_set",
	value = {
	    {
		type = "textarea",
		name = "note",
		label = "Notes",
		cols = 80,
		rows = 8,
		value = model.get_note(name)
	    },
	    {
		type = "submit",
		label = "Command",
		value = "Save"
	    }
	}
    }
end

local function mkerr(str)
    return {
	{
	    type = "formtext",
	    class = "error",
	    value = str
	}
    }
end

local function mkresult(str)
    return {
	{
	    type = "formtext",
	    value = str
	}
    }
end

local function chrun(model, name, ucmd)
    local cmd = string.lower(ucmd)
    --TODO chect that name is in get_service_names()
    if cmd ~= "start" and cmd ~= "stop" and cmd ~= "restart" then
	return mkerr("unknown command")
    end
    return mkresult(model.initd(name, cmd))
end

local function build_log_file(model, name)
    return {
	type = "group",
	label = name,
	text = "FILE " .. model.get_log_names()[name].path,
	value = {
	    {
		type = "log",
		lines = model.get_log_producer(name)
	    }
	}
    }
end

local function build_edit_file(model, name)
    return {
	type = "form",
	method = "post",
	action = cf.uri .. "/cfg_set",
	value = {
	    {
		type = "textarea",
		name = "cfg",
		label = name,
		cols = 80,
		rows = 12,
		value = model.get_cfg(name)
	    },
	    {
		type = "hidden",
		name = "name",
		value = name
	    },
	    {
		type = "submit",
		label = "Command",
		value = "Save"
	    }
	}
    }

end

local function build_cfg(model)
    local ret = {}
    for name, whatever in pairs(model.get_cfg_names()) do
	table.insert(ret, build_edit_file(model, name))
    end
    return ret
end

local function set_cfg(model)
    for name, whatever in pairs(model.get_cfg_names()) do
	if name == FORM.name then
	    model.set_cfg(name, FORM.cfg)
	    return
	end
    end 
    return mkerr("unknown config")
end

local function build_log(model)
    local ret = {}
    for name, whatever in pairs(model.get_log_names()) do
	table.insert(ret, build_log_file(model, name))
    end
    return ret 
end

local function build_service(model)
    local ret = {}
    for name, whatever in pairs(model.get_service_names()) do
	table.insert(ret, build_status(model, name))
    end
    table.insert(ret, build_note(model))
    return ret
end

function create_service_controller()

    local me = {}

    me.service = build_service
    me.default = me.service
    me.cfg = build_cfg
    me.log = build_log

    function me.chrun(model)
	return chrun(model, FORM.service, FORM.cmd)
    end

    function me.note_set(model)
	local ret = model.set_note(FORM.note)
	if ret then
	    return ret
	end
	return me.service(model)
    end


    function me.cfg_set(model)
	set_cfg(model)
	return me.cfg(model)
    end

    return me

end

-- /* vim: set filetype=lua shiftwidth=4: */

