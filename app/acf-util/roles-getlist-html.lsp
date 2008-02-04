<? local view= ... ?> 
<h1>Controller Status</h1>
<? for a,b in pairs(view.contlist.value) do 
print("<b>",a,"</b>")
for k,v in pairs(b) do print(v) end
print("<br>")
end ?>
