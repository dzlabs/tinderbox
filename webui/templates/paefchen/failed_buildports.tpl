<?
$topmenu = array();
$header_title = $build_name
	? "Build Failures in $build_name"
	: "All Build Failures";
if ($maintainer)
	$header_title .= " for $maintainer";
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/failed_buildports.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<?if(!$no_list){?>
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
	</tr>
<?}?>
</table>
<?}else{?>
<p>There are no build failures at the moment.</p>
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
