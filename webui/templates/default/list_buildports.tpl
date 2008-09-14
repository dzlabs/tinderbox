<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/list_buildports.tpl,v 1.13 2008/09/14 16:22:14 marcus Exp $ //-->
<title><?php echo $tinderbox_name?></title>
<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
<link rel="alternate" type="application/rss+xml" title="<?php echo $tinderbox_name?> (RSS)" href="index.php?action=latest_buildports_rss" />
</head>
<body>
<h1><?php echo $tinderbox_title?> - <?php echo $build_name?></h1>
<table>
 <tr>
  <td>Description</td>
  <td><?php echo $build_description?></td>
 </tr>
 <tr>
  <td>System</td>
  <td>FreeBSD <?php echo $jail_name?> (<?php echo $jail_tag?>) updated on <?php echo $jail_lastbuilt?></td>
 </tr>
 <tr>
  <td>Ports Tree</td>
  <td><?php echo $ports_tree_description?> updated on <?php echo $ports_tree_lastbuilt?></td>
 </tr>
</table>
 <form method="get" action="index.php">
<p>
 <a href="index.php?action=latest_buildports&amp;build=<?php echo $build_name?>">Current and latest builds in this build</a><br />
 <a href="index.php?action=failed_buildports&amp;build=<?php echo $build_name?>">Failed builds in this build</a><br />
 <input type="hidden" name="action" value="failed_buildports" />
 <input type="hidden" name="build" value="<?php echo $build_name?>" />
 Failed builds in this build for the maintainer <select name="maintainer">
 	<option></option>
 <?php foreach($maintainers as $maintainer) {?>
 	<option><?php echo $maintainer?></option>
 <?php }?>
 </select>
 <input type="submit" name="Go" value="Go" /><br />
 <a href="index.php">Back to homepage</a>
</p>
 </form>

<?php if(!$no_list){?>
	<table>
		<tr>
			<th>
				<a href="<?php echo  build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "port_directory") ?>">Port Directory</a>
			</th>
			<th>
				<a href="<?php echo  build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "port_maintainer") ?>">Maintainer</a>
			</th>
			<th>
				<a href="<?php echo  build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "last_built_version") ?>">Version</a>
			</th>
			<th style="width: 20px">&nbsp;</th>
			<th>
				<a href="<?php echo  build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "last_fail_reason") ?>">Reason</a>
			</th>
			<th>&nbsp;</th>
			<th>
				<a href="<?php echo  build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "last_built") ?>">Last Build Attempt</a>
			</th>
			<th>
				<a href="<?php echo  build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "last_successful_built") ?>">Last Successful Build</a>
			</th>
		</tr>
		<?php foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=describe_port&amp;id=<?php echo $row['port_id']?>"><?php echo $row['port_directory']?></a></td>
				<td><?php echo $row['port_maintainer']?></td>
				<td><?php echo $row['port_last_built_version']?></td>
				<td class="<?php echo $row['status_field_class']?>"><?php echo $row['status_field_letter']?></td>
				<?php $reason=$row['port_last_fail_reason']?>
				<td class="<?php echo "fail_reason_".$port_fail_reasons[$reason]['type']?>">
				<?php $href=($port_fail_reasons[$reason]['link']) ? "index.php?action=display_failure_reasons&amp;failure_reason_tag=$reason#$reason" : "#"?>
				<a href="<?php echo $href?>" class="<?php echo "fail_reason_".$port_fail_reasons[$reason]['type']?>" title="<?php echo $port_fail_reasons[$reason]['descr']?>"><?php echo $reason?></a>
				</td>
				<td>
					<?php if($row['port_link_logfile']){?>
						<a href="<?php echo $row['port_link_logfile']?>">log</a>
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
	<p>Total: <?php echo count($data)?></p>
<?php }else{?>
	<p>No ports are being built.</p>
<?php }?>

<p>Local time: <?php echo $local_time?></p>

 <form method="get" action="index.php">
<p>
 <a href="index.php?action=latest_buildports&amp;build=<?php echo $build_name?>">Current and latest builds in this build</a><br />
 <a href="index.php?action=failed_buildports&amp;build=<?php echo $build_name?>">Failed builds in this build</a><br />
 <input type="hidden" name="action" value="failed_buildports" />
 <input type="hidden" name="build" value="<?php echo $build_name?>" />
 Failed builds in this build for the maintainer <select name="maintainer">
 	<option></option>
 <?php foreach($maintainers as $maintainer) {?>
 	<option><?php echo $maintainer?></option>
 <?php }?>
 </select>
 <input type="submit" name="Go" value="Go" /><br />
 <a href="index.php">Back to homepage</a>
</p>
 </form>
<p style="color:#FF0000;font-size:10px;"><?php echo $ui_elapsed_time?></p>
<?php echo $display_login?>
</body>
</html>
