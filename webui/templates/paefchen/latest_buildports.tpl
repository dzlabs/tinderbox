<?php
$header_title = "Current and Latest Builds";
if ($build_name)
	$header_title .= " in $build_name";
$topmenu = array(
	'Current'	=> '#current',
	'Latest'	=> '#latest',
	'All Build Failures'=> 'index.php?action=failed_buildports',
	'All Failures'		=> 'index.php?action=bad_buildports',
	'RSS Feed'			=> 'index.php?action=latest_buildports_rss'

);
include 'header.inc.tpl'
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/latest_buildports.tpl,v 1.2 2008/01/07 03:53:59 as Exp $ //-->
<script type="text/javascript">
<!--
	function reloadpage() {
	    document.location.reload();
	}
	setTimeout("reloadpage()", <?php echo $reload_interval_latest ?>)
//-->
</script>
<?php echo $current_builds?>
<?php if($errors){?>
	<p style="color:#FF0000">
	<?php foreach($errors as $error){?>
		<?php echo $error?><br />
	<?php }?>
	</p>
<?php }?>
<?php if(!$no_list){?>
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

		<?php foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=list_buildports&amp;build=<?php echo $row['build_name']?>"><?php echo $row['build_name']?></a></td>
				<td><a href="index.php?action=describe_port&amp;id=<?php echo $row['port_id']?>"><?php echo $row['port_directory']?></a></td>
				<td><?php echo $row['port_last_built_version']?></td>
				<td class="<?php echo $row['status_field_class']?>"><?php echo $row['status_field_letter']?></td>
				<?php $reason=$row['port_last_fail_reason']?>
				<td class="<?php if(!empty($reason)) echo "fail_reason_".$port_fail_reasons[$reason]['type']?>">
				<?php $href=isset($port_fail_reasons[$reason]['link']) ? "index.php?action=display_failure_reasons&amp;failure_reason_tag=$reason#$reason" : "#"?>
				<a href="<?php echo $href?>" class="<?php if(!empty($reason)) echo "fail_reason_".$port_fail_reasons[$reason]['type']?>" title="<?php if(!empty($reason)) echo $port_fail_reasons[$reason]['descr']?>"><?php echo $reason?></a>
				</td>
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
	<?php if(!$errors){?>
		<p>No ports are being built.</p>
	<?php }?>
<?php }?>
<?php
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
