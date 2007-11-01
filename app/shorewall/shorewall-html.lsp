<?
local form = ...
?><h1>Edit <?= form.value.name.value
?></h1><?= html.form.start{
    method="POST",
    action= form.option.script .. "/" .. form.option.prefix
        .. form.option.controller .. "/" .. form.option.action ..
        form.option.extra
}
?><table><?
local myform = form.value 
local tags = {
    { "content", "longtext" },
    { "cmd", "action" },
    { "id", "hidden" },
}

for i,v in pairs(tags) do
    local name = v[1]
    local val = myform[name]
    val.type = v[2]
    ?><tr><td><?
--[[
    if val.label then
        io.write(val.label)
    elseif val.type ~= "hidden" then
        io.write(name)
    end
--]]
    ?></td><td><?
    if val.name == "" then val.name = name end
    if val.type == "longtext" then
       val.cols = 80
       val.rows = 24
    end
    ?><?= html.form[val.type](val)
    ?></td></tr><?
end
?></table><?= html.form.stop()
?>

