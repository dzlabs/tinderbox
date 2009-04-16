<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/failed_buildports.tpl,v 1.13 2009/04/16 15:41:47 beat Exp $ //-->
<title><?php echo $tinderbox_name?></title>
<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>

	<h1>

	<?php if($reason){?>
		Build by reason: <?php echo $reason?>
	<?php }else{?>
		<?php if($build_name){?>
			Build Failures in <?php echo $build_name?>
		<?php }else{?>
			All Build Failures
		<?php }?>
		<?php if($maintainer){?>
			for <?php echo $maintainer?>
		<?php }?>
	<?php }?>
	</h1>

<?php if($errors){?>
	<p style="color:#FF0000">
	<?php foreach($errors as $error){?>
		<?php echo $error?><br />
	<?php }?>
	</p>
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
				<a href="<?php echo $href?>" class="<?php if(!empty($port_fail_reasons[$reason]['type']))echo "fail_reason_".$port_fail_reasons[$reason]['type']?>" title="<?php if(!empty($port_fail_reasons[$reason]['descr']))echo $port_fail_reasons[$reason]['descr']?>"><?php echo $reason?></a>
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
			</tr>
		<?php }?>
	</table>
<?php }else{?>
	<?php if(!$errors){?>
		<p>There are no build failures at the moment.</p>
	<?php }?>
<?php }?>

<p>Local time: <?php echo $local_time?></p>
<p style="color:#FF0000;font-size:10px;"><?php echo $ui_elapsed_time?></p>
<p style="color:#FF0000;font-size:10px;"><?php echo $mem_info?></p>
<?php echo $display_login?>
<p><a href="index.php">Back to homepage</a></p>
</body>
</html>
