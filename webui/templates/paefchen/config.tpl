<?
$topmenu = array();
$header_title = 'Config';
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/config.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<?if($errors){?>
	<p style="color:#FF0000">
	<?foreach($errors as $error){?>
		<?=$error?><br />
	<?}?>
	</p>
<?} else {?>
<h2>configured builds:</h2>
<?if(!$no_build_list){?>
	<table>
		<tr>
			<th>Name</th>
			<th>Description</th>
			<th>Jail Name</th>
			<th>Ports Tree Name</th>
		</tr>

		<?foreach($build_data as $row) {?>
			<tr>
				<td><?=$row['build_name']?></td>
				<td><?=$row['build_description']?></td>
				<td><?=$row['jail_name']?></td>
				<td><?=$row['ports_tree_name']?></td>
			</tr>
		<?}?>

	</table>
<?}else{?>
	<p>There are no builds configured.</p>
<?}?>


<h2>configured jails:</h2>
<?if(!$no_jail_list){?>
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

		<?foreach($jail_data as $row) {?>
			<tr>
				<td><?=$row['jail_name']?></td>
				<td><?=$row['jail_arch']?></td>
				<td><?=$row['jail_description']?></td>
				<td><?=$row['jail_last_built']?></td>
				<td><?=$row['jail_tag']?></td>
				<td><?=$row['jail_update_cmd']?></td>
				<td><?=$row['jail_src_mount']?></td>
			</tr>
		<?}?>

	</table>
<?}else{?>
	<p>There are no jails configured.</p>
<?}?>


<h2>configured ports trees:</h2>
<?if(!$no_ports_tree_list){?>
	<table>
		<tr>
			<th>Name</th>
			<th>Description</th>
			<th>Last Built</th>
			<th>Update Cmd</th>
			<th>CVSWeb URL</th>
			<th>Ports Mount</th>
		</tr>

		<?foreach($ports_tree_data as $row) {?>
			<tr>
				<td><?=$row['ports_tree_name']?></td>
				<td><?=$row['ports_tree_description']?></td>
				<td><?=$row['ports_tree_last_built']?></td>
				<td><?=$row['ports_tree_update_cmd']?></td>
				<td><?=$row['ports_tree_cvsweb_url']?></td>
				<td><?=$row['ports_tree_ports_mount']?></td>
			</tr>
		<?}?>

	</table>
<?}else{?>
	<p>There are no ports trees configured.</p>
<?}?>

<h2>further configurations:</h2>
<?if(!$no_config_option_list){?>
	<table>
		<tr>
			<th>Name</th>
			<th>Value</th>
		</tr>

		<?foreach($config_option_data as $row) {?>
			<tr>
				<td><?=$row['config_option_name']?></td>
				<td><?=$row['config_option_value']?></td>
			</tr>
		<?}?>

	</table>
<?}else{?>
	<p>There are no further configurations.</p>
<?
	}
}
include 'footer.inc.tpl';
?>
