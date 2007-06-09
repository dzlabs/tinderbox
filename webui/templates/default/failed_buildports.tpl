<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/failed_buildports.tpl,v 1.6 2007/06/09 22:09:12 marcus Exp $ //-->
<title><?=$tinderbox_name?></title>
<link href="<?=$templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>

	<h1>
	<?if($build_name){?>
		Build Failures in <?=$build_name?>
	<?}else{?>
		All Build Failures
	<?}?>
	<?if($maintainer){?>
		for <?=$maintainer?>
	<?}?>
	</h1>


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
<?}?>

<p>Local time: <?=$local_time?></p>
<?=$display_login?>
<p><a href="index.php">Back to homepage</a></p>
</body>
</html>
