<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/user_properties.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<table>
	<tr>
		<th>Username</th>
		<th>Email</th>
		<th>Password</th>
		<th>Enable for WWW</th>
	</tr>
	<tr>
	<?if($www_admin){?>
		<td align="center"><input type="text" size="20" name="user_name" value="<?=$user_name?>" /></td>
	<?}else{?>
		<td align="center"><input type="hidden" name="user_name" value="<?=$user_name?>"><?=$user_name?></td>
	<?}?>
		<td align="center"><input type="text" size="20" name="user_email" value="<?=$user_email?>" /></td>
		<td align="center"><input type="password" size="20" name="user_password" value="<?=$user_password?>" /></td>
		<td align="center"><input type="hidden" name="user_id" value="<?=$user_id?>"><input type="checkbox" name="www_enabled" value="1" <?if($www_enabled == 1 ) {?>checked="checked"<?}?> /></td>
	</tr>
</table>
