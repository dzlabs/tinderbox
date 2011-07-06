<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/config.tpl,v 1.7 2011/07/06 18:54:52 beat Exp $ //-->
<title><?php echo $tinderbox_name?></title>
<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1><?php echo $tinderbox_title?> Config</h1>
<?php if($errors){?>
	<p style="color:#FF0000">
	<?php foreach($errors as $error){?>
		<?php echo $error?><br />
	<?php }?>
	</p>
<?php } else {?>
<h2>configured builds:</h2>
<?php if(!$no_build_list){?>
	<table>
		<tr>
			<th>Name</th>
			<th>Description</th>
			<th>Jail Name</th>
			<th>Ports Tree Name</th>
		</tr>

		<?php foreach($build_data as $row) {?>
			<tr>
				<td><?php echo $row['build_name']?></td>
				<td><?php echo $row['build_description']?></td>
				<td><?php echo $row['jail_name']?></td>
				<td><?php echo $row['ports_tree_name']?></td>
			</tr>
		<?php }?>

	</table>
<?php }else{?>
	<p>There are no builds configured.</p>
<?php }?>


<h2>configured jails:</h2>
<?php if(!$no_jail_list){?>
	<table>
		<tr>
			<th>Name</th>
			<th>Architecture</th>
			<th>Description</th>
			<th>Last Built</th>
			<th>Tag</th>
			<th>Update Cmd</th>
			<th>Src Mount</th>
		</tr>

		<?php foreach($jail_data as $row) {?>
			<tr>
				<td><?php echo $row['jail_name']?></td>
				<td><?php echo $row['jail_arch']?></td>
				<td><?php echo $row['jail_description']?></td>
				<td><?php echo $row['jail_last_built']?></td>
				<td><?php echo $row['jail_tag']?></td>
				<td><?php echo $row['jail_update_cmd']?></td>
				<td><?php echo $row['jail_src_mount']?></td>
			</tr>
		<?php }?>

	</table>
<?php }else{?>
	<p>There are no jails configured.</p>
<?php }?>


<h2>configured ports trees:</h2>
<?php if(!$no_ports_tree_list){?>
	<table>
		<tr>
			<th>Name</th>
			<th>Description</th>
			<th>Last Built</th>
			<th>Update Cmd</th>
			<th>CVSWeb URL</th>
			<th>Ports Mount</th>
		</tr>

		<?php foreach($ports_tree_data as $row) {?>
			<tr>
				<td><?php echo $row['ports_tree_name']?></td>
				<td><?php echo $row['ports_tree_description']?></td>
				<td><?php echo $row['ports_tree_last_built']?></td>
				<td><?php echo $row['ports_tree_update_cmd']?></td>
				<td><?php echo $row['ports_tree_cvsweb_url']?></td>
				<td><?php echo $row['ports_tree_ports_mount']?></td>
			</tr>
		<?php }?>

	</table>
<?php }else{?>
	<p>There are no ports trees configured.</p>
<?php }?>

<h2>configured hooks:</h2>
<?php if(!$no_hook_list){?>
	<table>
		<tr>
			<th>Name</th>
			<th>Command</th>
			<th>Description</th>
		</tr>

		<?php foreach($hook_data as $row) {?>
			<tr>
				<td><?php echo $row['hook_name']?></td>
				<td><?php echo $row['hook_cmd']?></td>
				<td><pre><?php echo $row['hook_description']?></pre></td>
			</tr>
		<?php }?>
	</table>
<?php }else{?>
	<p>There are no hooks configured.</p>
<?php }?>

<h2>further configurations:</h2>
<?php if(!$no_config_option_list){?>
	<table>
		<tr>
			<th>Name</th>
			<th>Value</th>
		</tr>

		<?php foreach($config_option_data as $row) {?>
			<tr>
				<td><?php echo $row['config_option_name']?></td>
				<td><?php echo $row['config_option_value']?></td>
			</tr>
		<?php }?>

	</table>
<?php }else{?>
	<p>There are no further configurations.</p>
<?php }?>



<?php }?>
<p><a href="index.php">Back to homepage</a></p>
<?php echo $display_login?>
</body>
</html>
