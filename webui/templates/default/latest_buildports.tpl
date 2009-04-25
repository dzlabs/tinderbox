<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/latest_buildports.tpl,v 1.18 2009/04/25 09:44:12 beat Exp $ //-->
<script language="JavaScript">
	function reloadpage() {
	    document.location.reload();
	}
	setTimeout("reloadpage()", <?php echo $reload_interval_latest ?>)
</script>
<title><?php echo $tinderbox_name?></title>
<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<?php if($errors){?>
	<p style="color:#FF0000">
	<?php foreach($errors as $error){?>
		<?php echo $error?><br />
	<?php }?>
	</p>
<?php }?>
<?php echo $current_builds?>

	<?php if($build_name){?>
		<h1>Latest Builds in <?php echo $build_name?></h1>
	<?php }else{?>
		<h1>Latest Builds</h1>
	<?php }?>

<?php if(!$no_list){?>
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
				<td class="<?php if(!empty($port_fail_reasons[$reason]['type']))echo "fail_reason_".$port_fail_reasons[$reason]['type']?>">
				<?php $href=isset($port_fail_reasons[$reason]['link']) ? "index.php?action=display_failure_reasons&amp;failure_reason_tag=$reason#$reason" : "#"?>
				<a href="<?php echo $href?>" class="<?php if(!empty($port_fail_reasons[$reason]['type']))echo "fail_reason_".$port_fail_reasons[$reason]['type']?>" title="<?php if(!empty($port_fail_reasons[$reason]['descr']))echo $port_fail_reasons[$reason]['descr']?>"><?php $reason?></a>
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

<p>
<a href="index.php?action=failed_buildports">All Build Failures</a><br />
<a href="index.php?action=bad_buildports">All (really) Build Failures</a><br />
<a href="index.php?action=latest_buildports_rss">RSS Feed</a><br />
<p>
<p>Local time: <?php echo $local_time?></p>
<p style="color:#FF0000;font-size:10px;"><?php echo $ui_elapsed_time?></p>
<p style="color:#FF0000;font-size:10px;"><?php echo $mem_info?></p>
<?php echo $display_login?>
<p><a href="index.php">Back to homepage</a></p>
</body>
</html>
