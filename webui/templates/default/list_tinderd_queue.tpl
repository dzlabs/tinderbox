<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!-- $MCom: portstools/tinderbox/webui/templates/default/list_tinderd_queue.tpl,v 1.15 2008/09/15 12:41:18 beat Exp $ //-->
<title><?php echo $tinderbox_name?></title>
<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1><?php echo $tinderbox_title?> - Tinderd Administration</h1>
<form method="get" action="index.php">
<input type="hidden" name="action" value="list_tinderd_queue" />
<table>
<tr>
<td>
Build
</td>
<td>
<select name="filter_build_id">
	<option></option>
<?php foreach($all_builds as $build) {?>
	<option value="<?php echo $build['build_id']?>" <?php if ($build_id == $build['build_id']) {?>selected="selected"<?php }?> ><?php echo $build['build_name']?></option>
<?php }?>
</select>
</td>
</tr>
<tr>
<td colspan="2">
<input type="submit" name="display" value="display" /> 
</td>
</tr>
</table>
</form>

<?php if($errors){?>
	<p style="color:#FF0000">
	<?php foreach($errors as $error){?>
		<?php echo $error?><br />
	<?php }?>
	</p>
<?php }?>

	<table>
		<tr>
			<th>Build</th>
			<th>Priority</th>
			<th>Port Directory</th>
			<th>User</th>
			<th style="width: 20px">&nbsp</th>
			<th>Email On<br />Completion</th>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
		</tr>

		<form method="post" action="index.php">
		<input type="hidden" name="action" value="add_tinderd_queue" />
		<input type="hidden" name="entry_id" value="<?php echo $row['entry_id']?>" />
		<input type="hidden" name="filter_build_id" value="<?php echo $build_id?>" />
		<tr>
			<td>
			<br />
				<select name="new_build_id">
					<?php foreach($all_builds as $build) {?>
						<option value="<?php echo $build['build_id']?>" <?php if ($new_build_id == $build['build_id']) {?>selected<?php }?> ><?php echo $build['build_name']?></option>
					<?php }?>
				</select>
			</td>
			<td>
			<br />
				<select name="new_priority">
					<?php foreach($all_prio as $prio) {?>
						<option value="<?php echo $prio?>" <?php if ($new_priority == $prio) {?>selected<?php }?> ><?php echo $prio?></option>
					<?php }?>
				</select>
			</td>
			<td><br /><input type="text" size="20" name="new_port_directory" value="<?php echo $new_port_directory?>" /></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td align="center">
				<input type="checkbox" name="new_email_on_completion" value="1" <?php if($new_email_on_completion == 1 ) {?>checked="checked"<?php }?> />
			</td>
			<td colspan="3"><br /><input type="submit" name="add_tinderd_queue" value="add" /></td>
		</tr>
		</form>
<?php if(!$no_list){?>

		<?php foreach($entries as $row) {?>
			<form method="post" action="index.php">
			<input type="hidden" name="action" value="change_tinderd_queue" />
			<input type="hidden" name="entry_id" value="<?php echo $row['entry_id']?>" />
			<input type="hidden" name="filter_build_id" value="<?php echo $build_id?>" />
			<tr>
				<td>
					<?php if($row['modify'] == 1){?>
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
					<?php if($row['modify'] == 1){?>
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
			</tr>
			</form>
		<?php }?>
<?php }?>

	</table>
	<p>
		<form method="post" action="index.php">
			<input type="hidden" name="action" value="delete_tinderd_queue" />
			<input type="hidden" name="filter_build_id" value="<?php echo $build_id?>" />
			<input type="submit" name="delete_tinderd_queue" value="delete all built" />
			<input type="submit" name="delete_tinderd_queue" value="delete all" />
		</form>
	</p>
<p>
<a href="index.php">Back to homepage</a>
</p>
<?php echo $display_login?>
</body>
</html>
