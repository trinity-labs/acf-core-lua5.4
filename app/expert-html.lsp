<? local form, viewlibrary, page_info, session = ... ?>
<? require("viewfunctions") ?>

<? if viewlibrary and viewlibrary.dispatch_component then
	viewlibrary.dispatch_component("status")
end ?>

<?
local func = haserl.loadfile(page_info.viewfile:gsub(page_info.prefix..page_info.controller..".*$", "/") .. "filedetails-html.lsp")
func(form, viewlibrary, page_info, session)
?>

<? if viewlibrary and viewlibrary.dispatch_component then
	viewlibrary.dispatch_component("startstop")
end ?>
