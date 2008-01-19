<?
$header_title = "Current and Latest Builds";
if ($build_name)
	$header_title .= " in $build_name";
$topmenu = array(
	'Current'	=> '#current',
	'Latest'	=> '#latest'
);
include 'header.inc.tpl'
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/latest_buildports.tpl,v 1.2 2008/01/07 03:53:59 as Exp $ //-->
<script type="text/javascript">
<!--
	function reloadpage() {
	    document.location.reload();
	}
	setTimeout("reloadpage()", 300000)
//-->
</script>
<?=$current_builds?>
<?if(!$no_list){?>
	<h2 id="latest">Latest</h2>
	<table>
		<tr>
			<th>Build</th>
			<th>Port Directory</th>
			<th>Version</th>
			<th style="width: 20px">&nbsp;</th>
			<th>Reason</th>
			<th>&nbsp;</th>
			<th>Last Build Attempt</th>
			<th>Last Successful Build</th>
			<th>Duration</th>
		</tr>

		<?foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=list_buildports&amp;build=<?=$row['build_name']?>"><?=$row['build_name']?></a></td>
				<td><a href="index.php?action=describe_port&amp;id=<?=$row['port_id']?>"><?=$row['port_directory']?></a></td>
				<td><?=$row['port_last_built_version']?></td>
				<td class="<?=$row['status_field_class']?>"><?=$row['status_field_letter']?></td>
				<?$reason=$row['port_last_fail_reason']?>
				<td class="<?="fail_reason_".$port_fail_reasons[$reason]['type']?>">
				<?$href=($port_fail_reasons[$reason]['link']) ? "index.php?action=display_failure_reasons&amp;failure_reason_tag=$reason#$reason" : "#"?>
				<a href="<?=$href?>" class="<?="fail_reason_".$port_fail_reasons[$reason]['type']?>" title="<?=$port_fail_reasons[$reason]['descr']?>"><?=$reason?></a>
				</td>
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
	<p>No ports are being built.</p>
<?}?>
<?
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
