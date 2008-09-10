<?if(!$user_name){?>
	<form method="post" action="index.php">
<?if($errors){?>
	<p style="color:#FF0000">
	<?foreach($errors as $error){?>
		<?=$error?><br />
	<?}?>
	</p>
<?}?>
		<table>
		<tr>
			<td>Username</td>
			<td><input type="text" name="User_Name" /></td>
		</tr>
		<tr>
			<td>Password</td>
			<td><input type="password" name="User_Password" /></td>
		</tr>
		<tr>
			<td colspan="2"><input type="submit" name="do_login" value="login" /></td>
		</tr>
	</table>
	<p style="font-size:10px;"><b>Note:</b> The Tinderbox web interface requires cookies to be enabled.</p>
	</form>
<?}else{?>
	<table>
		<tr>
			<td><form method="post" action="index.php">
				<table class="noborder" style="margin-top:10px">
					<tr>
						<td class="noborder">Welcome <?=$user_name?>!</td>
						<td class="noborder"><input type="submit" name="do_logout" value="logout" /></td>
					</tr>
				</table>
			</form></td>
		</tr>
		<tr>
			<td><form method="post" action="index.php">
				<table class="noborder">
					<tr><td class="noborder"><a href="index.php?action=list_tinderd_queue" style="margin-left:10px">Tinderd Queue</a></td></tr>
					<?if($is_www_admin==1){?>
					<tr><td class="noborder"><a href="index.php?action=config" style="margin-left:10px">Tinderbox Config</a></td></tr>
					<tr><td class="noborder">
						<input type="hidden" name="action" value="display_modify_user" />
						<select name="modify_user_id" style="margin-left:10px">
						<?foreach($all_users as $user){?>
							<option value="<?=$user['user_id']?>" <?if ($user_name == $user['user_name']) {?>selected="selected"<?}?>><?=$user['user_name']?></option>
						<?}?>
						</select>
						<input type="submit" name="display_modify_user" value="Modify User" />
					</td></tr>
					<tr><td class="noborder"><a href="index.php?action=display_add_user" style="margin-left:10px">Add User</a></td></tr>
					<?}else{?>
					<tr><td class="noborder"><a href="index.php?action=display_modify_user&amp;modify_user_id=<?=$user_id?>" style="margin-left:10px">Modify User</a></td></tr>
					<?}?>
				</table>
			</form></td>
		</tr>			
	</table>
<?}?>
