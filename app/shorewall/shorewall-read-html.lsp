<?
local view = ...
?><h1>Edit</h1><table border=0><?
local sct=""
for i,item in ipairs(view.list) do
    if item.section ~= sct then
        ?><tr><td colspan='2'><h2><?= item.section ?></td></tr><?
        sct = item.section
    end
    ?><tr><td><?= html.link{
        value = view.script .. view.prefix .. view.controller .. "/"
        .. view.action .. "?id=" .. tostring(item.id),
        label=item.name
    }
    ?></td><td><?= item.descr
    ?></td></tr><? 
end
?></table>
