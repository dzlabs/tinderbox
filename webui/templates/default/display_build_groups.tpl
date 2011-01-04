<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/display_build_groups.tpl,v 1.2 2011/01/04 15:03:58 beat Exp $ //-->
<title><?php echo $tinderbox_name?></title>
<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<?php if($errors){?>
	<p style="color:#FF0000">
	<?php foreach($errors as $error){?>
		<?php echo $error?><br />
	<?php }?>
	</p>
<?php }?>
<?php if(!$no_list){?>
		<p>Build Groups</p>
		<table>
				<tr>
						<th>Build Group Name</th>
						<th>Build Name</th>
						<th>&nbsp;</th>
				</tr>

				<?php foreach($data as $row) {?>
						<tr>
							<form method="post" action="index.php">
								<td>
										<?php echo $row['build_group_name']?>
								</td>
								<td>
										<?php echo $row['build_name']?>
								</td>
								<td>
									<input type="hidden" name="action" value="delete_build_group" />
									<input type="hidden" name="build_group_name" value="<?php echo $row['build_group_name']?>" />
									<input type="hidden" name="build_name" value="<?php echo $row['build_name']?>" />
									<input type="submit" name="delete_build_group" value="delete" />
								</td>
							</form>
						</tr>
				<?php }?>

		</table>
<?php }else{?>
		<p>There are no build groups configured.</p>
<?php }?>
<?php if($is_logged_in) {?>
		<p>Add Build Group</p>
		<form method="post" action="index.php">
				<fieldset>
						<table>
								<input type="hidden" name="action" value="add_build_group" />
								<tr>
										<th>Build</th>
										<th>Build Group Name</th>
										<th>&nbsp;</th>
								</tr>
								<tr>
										<td>
												<select name="build_id">
														<?php foreach($builds as $build) {?>
																<option value="<?php echo $build['build_id']?>"><?php echo $build['build_name']?></option>
														<?php }?>
												</select>
										</td>
										<td><input type="text" size="20" name="build_group_name" /></td>
										<td colspan="3"><input type="submit" name="add_build_group" value="add" /></td>
								</tr>
						</table>
				</fieldset>
		</form>
<?php }?>

<p style="color:#FF0000;font-size:10px;"><?php echo $ui_elapsed_time?></p>
<p style="color:#FF0000;font-size:10px;"><?php echo $mem_info?></p>
<?php echo $display_login?>
<p><a href="index.php">Back to homepage</a></p>
</body>
</html>
