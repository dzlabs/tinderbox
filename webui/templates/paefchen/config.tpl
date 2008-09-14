<?php
$topmenu = array();
$header_title = 'Config';
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/config.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
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
<?php
	}
}
include 'footer.inc.tpl';
?>
