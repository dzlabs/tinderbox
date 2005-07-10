<table>
	<tr>
		<th>Username</th>
		<th>Email</th>
		<th>Password</th>
		<th>Enable<br />for WWW</th>
	</tr>
	<tr>
		<td align="center"><input type="text" size="20" name="user_name" value="<?=$user_name?>" /></td>
		<td align="center"><input type="text" size="20" name="user_email" value="<?=$user_email?>" /></td>
		<td align="center"><input type="password" size="20" name="user_password" value="<?=$user_password?>" /></td>
		<td align="center"><input type="checkbox" name="www_enabled" value="1" <?if($www_enabled == 1 ) {?>checked="checked"<?}?> /></td>
	</tr>
</table>
