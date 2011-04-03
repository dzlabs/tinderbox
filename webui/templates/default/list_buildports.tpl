<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/list_buildports.tpl,v 1.21 2011/04/03 01:01:30 beat Exp $ //-->
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
</p>
 </form>
 <form method="get" action="index.php">
<p>
 Find ports by name
 <input type="hidden" name="action" value="list_buildports" />
 <input type="hidden" name="build" value="<?php echo $build_name?>" />
 <input type="text" name="search_port_name" value="<?php echo $search_port_name?>" />
 <input type="submit" name="Go" value="Go" />
</p>
 </form>
<p>
 <a href="index.php">Back to homepage</a>
</p>

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
						<?php if($row['port_link_wrksrc']){?>
							<a href="<?php echo $row['port_link_package']?>">wrksrc</a>
						<?php }else{?>
							<a href="<?php echo $row['port_link_package']?>">package</a>
						<?php }?>
					<?php }?>
					<?php if($is_logged_in) {?>
						<a href="index.php?action=add_tinderd_queue&amp;new_build_id=<?php echo $build_id?>&amp;new_port_directory=<?php echo $row['port_directory']?>&amp;new_priority=10&amp;new_email_on_completion=0&amp;add_tinderd_queue=add&amp;filter_build_id=">requeue</a>
					<?php }?>
				</td>
				<td><?php echo $row['port_last_built']?></td>
				<td><?php echo $row['port_last_successful_built']?></td>
			</tr>
		<?php }?>
	</table>
	<p>Total: <?php echo count($data)?></p>
	<p>
		<?php if($list_nr_prev!=-1){?>
			<a href="<?php echo build_query_string($_SERVER['PHP_SELF'], $querystring, "list_limit_offset", $list_nr_prev ) ?>">prev</a>
		<?php }?>
		<?php if($list_nr_next!=0){?>
			<a href="<?php echo build_query_string($_SERVER['PHP_SELF'], $querystring, "list_limit_offset", $list_nr_next ) ?>">next</a>
		<?php }?>
	</p>
<?php }else{?>
	<?php if(!$errors){?>
		<p>No ports are being built.</p>
	<?php }?>
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
<p style="color:#FF0000;font-size:10px;"><?php echo $mem_info?></p>
<?php echo $display_login?>
</body>
</html>
