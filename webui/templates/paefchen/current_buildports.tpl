<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/current_buildports.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<?if(!$no_list){?>
	<h2 id="current">Current</h2>
	<table>
		<tr>
			<th>Build</th>
			<th>Port</th>
			<th>Duration</th>
			<th>ETA</th>
		</tr>
		<?foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=list_buildports&amp;build=<?=$row['build_name']?>"><?=$row['build_name']?></a></td>
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
