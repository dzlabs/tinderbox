<!-- $MCom: portstools/tinderbox/webui/templates/default/current_buildports.tpl,v 1.6 2008/08/28 20:58:54 beat Exp $ //-->
<?if(!$no_list){?>
	<?if($build_name){?>
		<h1>Current Builds in <?=$build_name?></h1>
	<?}else{?>
		<h1>Current Builds</h1>
	<?}?>
	<table>
		<tr>
			<th>Build</th>
			<th>Target Port</th>
			<th>Port</th>
			<th>Duration</th>
			<th>ETA</th>
		</tr>
		<?foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=list_buildports&amp;build=<?=$row['build_name']?>"><?=$row['build_name']?></a></td>
				<td><?=$row['target_port']?></td>
				<td><?=$row['port_current_version']?></td>
				<td><?=time_difference_from_now($row['build_last_updated'])?></td>
				<td><?=is_string($row['build_eta'])?$row['build_eta']:time_elapsed($row['build_eta'])?></td>
			</tr>
		<?}?>
	</table>
	<script language="JavaScript">
		setTimeout("reloadpage()", 60000)
	</script>
<?}?>
