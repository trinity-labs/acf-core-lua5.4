<? view = ... ?>
<? --[[
	io.write(html.cfe_unpack(view))
--]] ?>

<style type="text/css">
	p.hiddendetail {
		display: none;
	}
	p.error a{
		display: block;
		font-weight: normal;
		font-size: 75%;
	}
</style>
<script type="text/javascript" src="/js/jquery-latest.js"></script>
<script type="text/javascript">
	var clickIt = function(){
			$("p.hiddendetail").removeClass("hiddendetail").show("slow");
			$(this).fadeOut("slow");
	};
	$(document).ready(function(){
		$("p.errordetail").append('<a href="javascript:;">Show Detail</a>').find("a").click(clickIt);
		$("p.errordetail").addClass("error");
	});
</script>

<h1>Alpine Configuration Framework</h1>
<p class="errordetail">Dispatch error occured</p>
<p class="hiddendetail">'<?= view.controller ?>' does not have a '<?= view.action ?>' action.</p>
