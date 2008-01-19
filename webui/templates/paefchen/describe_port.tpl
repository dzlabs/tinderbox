<?
$topmenu = array();
$header_title = $port_name;
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/describe_port.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<?if(!$no_list){?>
<div class="description">
	<table>
		<tr>
			<th>Directory</th>
			<td><?=$port_dir?> (
			<?for($i=0;$i<count($ports_trees_links);$i++) {?>
				<a href="<?=$ports_trees_links[$i]['cvsweb']?>/<?=$port_dir?><?=$ports_trees_links[$i]['cvsweb_querystr']?>"><?=$ports_trees_links[$i]['name']?></a>
			<?}?>
			)</td>
		</tr>
		<tr>
			<th>Comment</th>
			<td><?=$port_comment?></td>
		</tr>
		<tr>
			<th>Maintainer</th>
			<td><a href="mailto:<?=$port_maintainer?>"><?=$port_maintainer?></a></td>
		</tr>
	</table>
</div>
	<table>
		<tr>
			<th>Build</th>
			<th>Version</th>
			<th style="width: 20px">&nbsp;</th>
			<th>&nbsp;</th>
			<th>Last Build Attempt</th>
			<th>Last Successful Build</th>
			<th>Duration</th>
		</tr>
		<?foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=list_buildports&amp;build=<?=$row['build_name']?>"><?=$row['build_name']?></a></td>
				<td><?=$row['port_last_built_version']?></td>
				<td class="<?=$row['status_field_class']?>"><?=$row['status_field_letter']?></td>
				<td>
					<?if($row['port_link_logfile']){?>
						<a href="<?=$row['port_link_logfile']?>">log</a>
					<?}?>
					<?if($row['port_link_package']){?>
						<a href="<?=$row['port_link_package']?>">package</a>
					<?}?>
				</td>
				<td><?=$row['port_last_built']?></td>
				<td><?=$row['port_last_successful_built']?></td>
				<td><?=time_elapsed($row['port_last_run_duration'])?></td>
			</tr>
		<?}?>
	</table>
<?}else{?>
	<p>Invalid port ID.</p>
<? }
$footer_legend = array(
	'port_success'	=> 'Success',
	'port_default'	=> 'Default',
	'port_leftovers'=> 'Leftovers', # L
	'port_dud'		=> 'Dud', # D
	'port_depend'	=> 'Depend',
	'port_fail'		=> 'Fail',
);
include 'footer.inc.tpl';
?>
