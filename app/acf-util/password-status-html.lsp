<? local form = ... ?>
<?
--[[ DEBUG INFORMATION
io.write("<H1>DEBUGGING</H1><span style='color:red'><H2>DEBUG INFO: CFE</H2>")
io.write(html.cfe_unpack(form))
io.write("</span>")
--]]
?>

<H1>USER ACCOUNTS</H1>
<H2>Create new account</H2>
<form action="newuser" method="POST">
<dl><dt><input class="submit" type="submit" value="New User"></dt></dl>
</form>
<H2>Existing account</H2>
<DL>
<? for name,user in pairs(form.value) do ?>
	<DT><IMG SRC='/static/tango/16x16/apps/system-users.png' HEIGHT='16' WIDTH='16'> <?= name ?></DT>
	<DD><TABLE>
		<TR>
			<TD><B><?= user.value.userid.label ?></B></TD>
			<TD WIDTH='90%'><?= user.value.userid.value ?></TD>
		</TR><TR>
			<TD><B><?= user.value.username.label ?></B></TD>
			<TD><?= user.value.username.value ?></TD>
		</TR><TR>
			<TD><B><?= user.value.roles.label ?></B></TD>
			<TD><?= table.concat(user.value.roles.value, " / ") ?></TD>
		</TR><TR>
			<TD><B>Option</B></TD>
			<TD>
			[<A HREF='edituser?userid=<?= name ?>'>Edit this account</A>]
			[<A HREF='deleteuser?userid=<?= name ?>'>Delete this account</A>]
			</TD>
		</TR>
	</TABLE></DD>
<? end ?>
</DL>

<?
--[[ DEBUG INFORMATION
io.write("<H1>DEBUGGING</H1><span style='color:red'><H2>DEBUG INFO: CFE</H2>")
io.write(html.cfe_unpack(form))
io.write("</span>")
--]]
?>

