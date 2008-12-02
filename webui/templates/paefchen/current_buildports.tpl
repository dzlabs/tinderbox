<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/current_buildports.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<?php if(!$no_list){?>
	<h2 id="current">Current</h2>
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
		setTimeout("reloadpage()", <?php echo $reload_interval_current ?>)
	</script>
<?php }?>
