<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/www-exp/templates/default/list_tinderd_queue.tpl,v 1.2 2005/07/10 08:15:28 oliver Exp $ //-->
<title><?=$tinderbox_name?></title>
<link href="<?=$templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1><?=$tinderbox_title?> - Tinderd Administration</h1>
<form method="get" action="index.php">
<table>
<tr>
<td>
<input type="hidden" name="action" value="list_tinderd_queue" />
Host
</td>
<td>
 <select name="filter_host_id">
	<option></option>
<?foreach($all_hosts as $host) {?>
	<option value="<?=$host['host_id']?>" <?if ($host_id == $host['host_id']) {?>selected="selected"<?}?>><?=$host['host_name']?></option>
<?}?>
</select>
</td>
</tr>

<tr>
<td>
Build
</td>
<td>
<select name="filter_build_id">
	<option></option>
<?foreach($all_builds as $build) {?>
	<option value="<?=$build['build_id']?>" <?if ($build_id == $build['build_id']) {?>selected="selected"<?}?> ><?=$build['build_name']?></option>
<?}?>
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

<?if($errors){?>
	<p style="color:#FF0000">
	<?foreach($errors as $error){?>
		<?=$error?><br />
	<?}?>
	</p>
<?}?>

	<table>
		<tr>
			<th>Host</th>
			<th>Build</th>
			<th>Priority</th>
			<th>Port Directory</th>
			<th>User</th>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
		</tr>

<?if(!$no_list){?>

		<?foreach($entries as $row) {?>
			<form method="post" action="index.php">
			<input type="hidden" name="action" value="change_tinderd_queue" />
			<input type="hidden" name="entry_id" value="<?=$row['entry_id']?>" />
			<input type="hidden" name="filter_build_id" value="<?=$build_id?>" />
			<input type="hidden" name="filter_host_id" value="<?=$host_id?>" />
			<tr>
				<td>
					<?if($row['modify'] == 1){?>
						<select name="host_id">
							<?foreach($all_hosts as $host) {?>
								<option value="<?=$host['host_id']?>" <?if ($row['host'] == $host['host_name']) {?>selected<?}?>><?=$host['host_name']?></option>
							<?}?>
						</select>
					<?}else{?>
						<?=$row['host']?>
					<?}?>
				</td>
				<td>
					<?if($row['modify'] == 1){?>
						<select name="build_id">
							<?foreach($all_builds as $build) {?>
								<option value="<?=$build['build_id']?>" <?if ($row['build'] == $build['build_name']) {?>selected<?}?> ><?=$build['build_name']?></option>
							<?}?>
						</select>
					<?}else{?>
						<?=$row['build']?>
					<?}?>
				</td>
				<td>
					<?if($row['modify'] == 1){?>
						<select name="priority">
							<?foreach($row['all_prio'] as $prio) {?>
								<option value="<?=$prio?>" <?if ($row['priority'] == $prio) {?>selected<?}?> ><?=$prio?></option>
							<?}?>
						</select>
					<?}else{?>
						<?=$row['priority']?>
					<?}?>
				</td>
				<td><?=$row['directory']?></td>
				<td><?=$row['user']?></td>
				<td>
					<?if($row['modify'] == 1){?>
						<input type="submit" name="change_tinderd_queue" value="save" />
					<?}?>
				</td>
				<td>
					<?if($row['delete'] == 1){?>
						<input type="submit" name="change_tinderd_queue" value="delete" />
					<?}?>
				</td>
			</tr>
			</form>
		<?}?>
<?}?>
			<form method="post" action="index.php">
			<input type="hidden" name="action" value="add_tinderd_queue" />
			<input type="hidden" name="entry_id" value="<?=$row['entry_id']?>" />
			<input type="hidden" name="filter_build_id" value="<?=$build_id?>" />
			<input type="hidden" name="filter_host_id" value="<?=$host_id?>" />
			<tr>
				<td>
				<br />
					<select name="new_host_id">
						<?foreach($all_hosts as $host) {?>
							<option value="<?=$host['host_id']?>" <?if ($new_host_id == $host['host_id']) {?>selected<?}?>><?=$host['host_name']?></option>
						<?}?>
					</select>
				</td>
				<td>
				<br />
					<select name="new_build_id">
						<?foreach($all_builds as $build) {?>
							<option value="<?=$build['build_id']?>" <?if ($new_build_id == $build['build_id']) {?>selected<?}?> ><?=$build['build_name']?></option>
						<?}?>
					</select>
				</td>
				<td>
				<br />
					<select name="new_priority">
						<?foreach($all_prio as $prio) {?>
							<option value="<?=$prio?>" <?if ($new_priority == $prio) {?>selected<?}?> ><?=$prio?></option>
						<?}?>
					</select>
				</td>
				<td><br /><input type="text" size="20" name="new_port_directory" value="<?=$new_port_directory?>" /></td>
				<td>&nbsp;</td>
				<td><br /><input type="submit" name="add_tinderd_queue" value="add" /></td>
			</tr>
			</form>

	</table>


<p>
<a href="index.php">Back to homepage</a>
</p>
<?=$display_login?>
</body>
</html>
