<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/display_login.tpl,v 1.3 2008/01/07 04:16:24 as Exp $ //-->
<!-- user_name:<?=$user_name?>;user_id:<?=$user_id?>;is_www_admin:<?=$is_www_admin?> //-->
<? if (empty($user_name)) { ?>
	<form method="post" action="index.php">
		<fieldset>
			<label>Login</label>
	<? if ($errors) { ?>
			<p style="color:#FF0000">
		<? foreach($errors as $error){ ?>
				<?=$error?><br />
		<? } ?>
			</p>
	<?}?>
			<table>
				<tr>
					<td>Username</td>
					<td><input type="text" name="User_Name" /></td>
					<td>&nbsp;</td>
					<td>Password</td>
					<td><input type="password" name="User_Password" /></td>
					<td>&nbsp;</td>
					<td><input type="submit" name="do_login" value="login" /></td>
				</tr>
				<tr>
					<td colspan="7"><small><b>Note:</b> The Tinderbox web interface requires cookies to be enabled.</small></td>
				</tr>
			</table>
		</fieldset>
	</form>
<? } else if (! empty($user_name) && $is_www_admin == 1) { ?>
	<form method="post" action="index.php">
		<fieldset>
			<label>Modify User</label>
			<input type="hidden" name="action" value="display_modify_user" />
			<select name="modify_user_id">
		<?foreach($all_users as $user){?>
				<option value="<?=$user['user_id']?>" <?if ($user_name == $user['user_name']) {?>selected="selected"<?}?>><?=$user['user_name']?></option>
		<? } ?>
			</select>
			<input type="submit" name="display_modify_user" value="Modify User" />
		</fieldset>
	</form>
<? } ?>
