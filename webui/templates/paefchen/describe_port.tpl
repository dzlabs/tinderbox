<?php
$topmenu = array();
$header_title = $port_name;
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/describe_port.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<?php if(!$no_list){?>
<div class="description">
	<table>
		<tr>
			<th>Directory</th>
			<td><?php echo $port_dir?> (
			<?php for($i=0;$i<count($ports_trees_links);$i++) {?>
				<a href="<?php echo $ports_trees_links[$i]['cvsweb']?>/<?php echo $port_dir?><?php echo $ports_trees_links[$i]['cvsweb_querystr']?>"><?php echo $ports_trees_links[$i]['name']?></a>
			<?php }?>
			)</td>
		</tr>
		<tr>
			<th>Comment</th>
			<td><?php echo $port_comment?></td>
		</tr>
		<tr>
			<th>Maintainer</th>
			<td><a href="mailto:<?php echo $port_maintainer?>"><?php echo $port_maintainer?></a></td>
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
		<?php foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=list_buildports&amp;build=<?php echo $row['build_name']?>"><?php echo $row['build_name']?></a></td>
				<td><?php echo $row['port_last_built_version']?></td>
				<td class="<?php echo $row['status_field_class']?>"><?php echo $row['status_field_letter']?></td>
				<td>
					<?php if($row['port_link_logfile']){?>
						<a href="<?php echo $row['port_link_logfile']?>">log</a>
						<a href="index.php?action=display_markup_log&amp;build=<?php echo $row['build_name']?>&amp;id=<?php echo $row['port_id']?>">markup</a>
					<?php }?>
					<?php if($row['port_link_package']){?>
						<a href="<?php echo $row['port_link_package']?>">package</a>
					<?php }?>
				</td>
				<td><?php echo $row['port_last_built']?></td>
				<td><?php echo $row['port_last_successful_built']?></td>
				<td><?php echo time_elapsed($row['port_last_run_duration'])?></td>
			</tr>
		<?php }?>
	</table>
<?php }else{?>
	<p>Invalid port ID.</p>
<?php }
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
