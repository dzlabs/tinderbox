<!-- $MCom: portstools/tinderbox/webui/templates/default/current_buildports.tpl,v 1.7 2008/09/14 16:22:14 marcus Exp $ //-->
<?php if(!$no_list){?>
	<?php if($build_name){?>
		<h1>Current Builds in <?php echo $build_name?></h1>
	<?php }else{?>
		<h1>Current Builds</h1>
	<?php }?>
	<table>
		<tr>
			<th>Build</th>
			<th>Target Port</th>
			<th>Port</th>
			<th>Duration</th>
			<th>ETA</th>
		</tr>
		<?php foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=list_buildports&amp;build=<?php echo $row['build_name']?>"><?php echo $row['build_name']?></a></td>
				<td><?php echo $row['target_port']?></td>
				<td><?php echo $row['port_current_version']?></td>
				<td><?php echo time_difference_from_now($row['build_last_updated'])?></td>
				<td><?php echo is_string($row['build_eta'])?$row['build_eta']:time_elapsed($row['build_eta'])?></td>
			</tr>
		<?php }?>
	</table>
	<script language="JavaScript">
		setTimeout("reloadpage()", 60000)
	</script>
<?php }?>
