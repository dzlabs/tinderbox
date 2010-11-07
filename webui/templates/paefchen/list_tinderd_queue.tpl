<?php
$header_title = 'Tinderd Administration';
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/list_tinderd_queue.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<div class="subcontent">
	<table>
		<tr>
			<th>Build</th>
			<td>
				<form method="get" action="index.php">
				<fieldset>
				<input type="hidden" name="action" value="list_tinderd_queue" />
				<select name="filter_build_id">
					<option></option>
<?php foreach($all_builds as $build) {?>
					<option value="<?php echo $build['build_id']?>" <?php if ($build_id == $build['build_id']) {?>selected="selected"<?php }?> ><?php echo $build['build_name']?></option>
<?php }?>
				</select>
				<input type="submit" name="display" value="display" /> 
				</fieldset>
				</form>
			</td>
<?php if($is_logged_in) {?>
			<td style="background-color: #FFFFFF; width: 20px">&nbsp;</td>
				<td>
				<form method="post" action="index.php">
				<fieldset>
					<input type="hidden" name="action" value="delete_tinderd_queue" />
					<input type="hidden" name="filter_build_id" value="<?php echo $build_id?>" />
					<input type="submit" name="delete_tinderd_queue" value="delete all built" />
				</fieldset>
				</form>
				</td>
				<td style="background-color: #FFFFFF; width: 20px">&nbsp;</td>
				<td>
				<form method="post" action="index.php">
				<fieldset>
					<input type="hidden" name="action" value="delete_tinderd_queue" />
					<input type="submit" name="delete_tinderd_queue" value="delete all" />
				</fieldset>
				</form>
			</td>
<?php }?>
		</tr>
	</table>

<?php if($errors){?>
	<p style="color:#FF0000">
	<?php foreach($errors as $error){?>
		<?php echo $error?><br />
	<?php }?>
	</p>
<?php }?>

</div>

<table>
	<tr>
		<th>Build</th>
		<th>Priority</th>
		<th>Port Directory</th>
		<th>User</th>
		<th style="width: 20px">&nbsp;</th>
<?php if($is_logged_in) {?>
		<th>Email On Completion</th>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
<?php }?>
	</tr>
<?php if(!$is_logged_in && $no_list) {?>
	<tr>
		<td>Queue empty</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
<?php }?>
<?php if($is_logged_in) {?>
	<form method="post" action="index.php">
	<fieldset>
	<input type="hidden" name="action" value="add_tinderd_queue" />
	<input type="hidden" name="entry_id" value="<?php if(!empty($row['entry_id']))echo $row['entry_id']?>" />
	<input type="hidden" name="filter_build_id" value="<?php echo $build_id?>" />
	<tr>
		<td>
			<select name="new_build_id">
				<?php foreach($allowed_builds as $build) {?>
					<option value="<?php echo $build['build_id']?>" <?php if ($new_build_id == $build['build_id']) {?>selected<?php }?> ><?php echo $build['build_name']?></option>
				<?php }?>
			</select>
		</td>
		<td>
			<select name="new_priority">
				<?php foreach($all_prio as $prio) {?>
					<option value="<?php echo $prio?>" <?php if ($new_priority == $prio) {?>selected<?php }?> ><?php echo $prio?></option>
				<?php }?>
			</select>
		</td>
		<td><input type="text" size="20" name="new_port_directory" value="<?php echo $new_port_directory?>" /></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td align="center">
			<input type="checkbox" name="new_email_on_completion" value="1" <?php if($new_email_on_completion == 1 ) {?>checked="checked"<?php }?> />
		</td>
		<td colspan="3"><input type="submit" name="add_tinderd_queue" value="add" /></td>
	</tr>
	</fieldset>
	</form>
<?php }?>
<?php if(!$no_list){?>

		<?php foreach($entries as $row) {?>
			<form method="post" action="index.php">
			<fieldset>
			<input type="hidden" name="action" value="change_tinderd_queue" />
			<input type="hidden" name="entry_id" value="<?php echo $row['entry_id']?>" />
			<input type="hidden" name="filter_build_id" value="<?php echo $build_id?>" />
			<tr>
				<td>
					<?php if($is_logged_in && $row['modify'] == 1){?>
						<select name="build_id">
							<?php foreach($all_builds as $build) {?>
								<option value="<?php echo $build['build_id']?>" <?php if ($row['build'] == $build['build_name']) {?>selected<?php }?> ><?php echo $build['build_name']?></option>
							<?php }?>
						</select>
					<?php }else{?>
						<?php echo $row['build']?>
					<?php }?>
				</td>
				<td>
					<?php if($is_logged_in && $row['modify'] == 1){?>
						<select name="priority">
							<?php foreach($row['all_prio'] as $prio) {?>
								<option value="<?php echo $prio?>" <?php if ($row['priority'] == $prio) {?>selected<?php }?> ><?php echo $prio?></option>
							<?php }?>
						</select>
					<?php }else{?>
						<?php echo $row['priority']?>
					<?php }?>
				</td>
				<td><?php echo $row['directory']?></td>
				<td><?php echo $row['user']?></td>
				<td class="<?php echo $row['status_field_class']?>">&nbsp;</td>
<?php if($is_logged_in) {?>
				<td align="center">
					<?php if($row['modify'] == 1){?>
						<input type="checkbox" name="email_on_completion" value="1" <?php if($row['email_on_completion'] == 1 ) {?>checked="checked"<?php }?> />
					<?php }else{?>
						<?php if($row['email_on_completion'] == 1 ) {?>X"<?php }?>
					<?php }?>
				</td>
				<td>
					<?php if($row['modify'] == 1){?>
						<input type="submit" name="change_tinderd_queue" value="save" />
					<?php }?>
				</td>
				<td>
					<?php if($row['delete'] == 1){?>
						<input type="submit" name="change_tinderd_queue" value="delete" />
					<?php }?>
				</td>
				<td>
					<?php if($row['modify'] == 1){?>
						<input type="submit" name="change_tinderd_queue" value="reset status" />
					<?php }?>
				</td>
<?php }?>
			</tr>
			</fieldset>
			</form>
		<?php }?>
<?php }?>
</table>
<?php if($is_logged_in){?>
	<fieldset>
		<label>Build Group testing</label>
		<?php if(!$no_groups){?>
			<table>
				<form method="post" action="index.php">
					<input type="hidden" name="action" value="add_build_group_queue" />
					<tr>
						<th>Build Group</th>
						<th>Priority</th>
						<th>Port Directory</th>
						<th>Email On Completion</th>
						<th>&nbsp;</th>
					</tr>
					<tr>
						<td>
							<select name="build_group_name">
								<?php foreach($all_build_groups as $build_group) {?>
									<option value="<?php echo $build_group?>"><?php echo $build_group?></option>
								<?php }?>
							</select>
						</td>
						<td>
							<select name="new_priority">
								<?php foreach($all_prio as $prio) {?>
									<option value="<?php echo $prio?>" <?php if ($new_priority == $prio) {?>selected<?php }?> ><?php echo $prio?></option>
								<?php }?>
							</select>
						</td>
						<td><input type="text" size="20" name="new_port_directory" value="<?php echo $new_port_directory?>" /></td>
						<td align="center">
							<input type="checkbox" name="new_email_on_completion" value="1" <?php if($new_email_on_completion == 1 ) {?>checked="checked"<?php }?> />
						</td>
						<td><input type="submit" name="add_build_group_queue" value="add" /></td>
					</tr>	
				</form>
			</table>
		<?php }?>
	</fieldset>
	<br />
	<form method="post" action="index.php">
		<input type="hidden" name="action" value="list_build_group" />
		<input type="submit" name="list_build_group" value="Edit Build Groups" />
        </form>
<?php }?>
<?php if($is_logged_in) {?>
<table>
	<form method="post" action="index.php">
	<fieldset>
	<label>Mass testing</label>
	<input type="hidden" name="action" value="add_tinderd_queue" />
	<input type="hidden" name="entry_id" value="<?php if(!empty($row['entry_id']))echo $row['entry_id']?>" />
	<input type="hidden" name="filter_build_id" value="<?php echo $build_id?>" />
	<tr>
		<th>Build</th>
		<th>Priority</th>
		<th>Port Directories</th>
		<th>Email On Completion</th>
		<th>&nbsp;</th>
	</tr>
	<tr>
		<td>
			<select name="new_build_id">
				<?php foreach($allowed_builds as $build) {?>
					<option value="<?php echo $build['build_id']?>" <?php if ($new_build_id == $build['build_id']) {?>selected<?php }?> ><?php echo $build['build_name']?></option>
				<?php }?>
			</select>
		</td>
		<td>
			<select name="new_priority">
				<?php foreach($all_prio as $prio) {?>
					<option value="<?php echo $prio?>" <?php if ($new_priority == $prio) {?>selected<?php }?> ><?php echo $prio?></option>
				<?php }?>
			</select>
		</td>
		<td><textarea cols="30" rows="10" name="new_port_directory"></textarea></td>
		<td align="center">
			<input type="checkbox" name="new_email_on_completion" value="1" <?php if($new_email_on_completion == 1 ) {?>checked="checked"<?php }?> />
		</td>
		<td colspan="3"><input type="submit" name="add_tinderd_queue" value="add" /></td>
	</tr>
	</fieldset>
	</form>
</table>
<?php }?>
<?php include('footer.inc.tpl'); ?>
