<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/www-exp/templates/default/list_buildports.tpl,v 1.1 2005/07/01 18:09:38 oliver Exp $ //-->
<title><?=$tinderbox_name?></title>
<link href="<?=$templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1><?=$tinderbox_title?> - <?=$build_name?></h1>
<table>
 <tr>
  <td>Description</td>
  <td><?=$build_description?></td>
 </tr>
 <tr>
  <td>System</td>
  <td>FreeBSD <?=$jail_name?> (<?=$jail_tag?>) updated on <?=$jail_lastbuilt?></td>
 </tr>
 <tr>
  <td>Ports Tree</td>
  <td><?=$ports_tree_description?> updated on <?=$ports_tree_lastbuilt?></td>
 </tr>
</table>
 <form method="get" action="index.php">
<p>
 <a href="index.php?action=latest_buildports&amp;build=<?=$build_name?>">Current and latest builds in this build</a><br />
 <a href="index.php?action=failed_buildports&amp;build=<?=$build_name?>">Failed builds in this build</a><br />
 <input type="hidden" name="action" value="failed_buildports" />
 <input type="hidden" name="build" value="<?=$build_name?>" />
 Failed builds in this build for the maintainer <select name="maintainer">
 	<option></option>
 <?foreach($maintainers as $maintainer) {?>
 	<option><?=$maintainer?></option>
 <?}?>
 </select>
 <input type="submit" name="Go" value="Go" /><br />
 <a href="index.php">Back to homepage</a>
</p>
 </form>

<?if(!$no_list){?>
	<table>
		<tr>
			<th>Port Directory</th>
			<th>Maintainer</th>
			<th>Version</th>
			<th style="width: 20px">&nbsp;</th>
			<th>&nbsp;</th>
			<th>Last Build Attempt</th>
			<th>Last Successful Build</th>
		</tr>
		<?foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=describe_port&amp;id=<?=$row['port_id']?>"><?=$row['port_directory']?></a></td>
				<td><?=$row['port_maintainer']?></td>
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
			</tr>
		<?}?>
	</table>
<?}else{?>
	<p>No ports are being build</p>
<?}?>

<p>Local time: <?=$local_time?></p>

 <form method="get" action="index.php">
<p>
 <a href="index.php?action=latest_buildports&amp;build=<?=$build_name?>">Current and latest builds in this build</a><br />
 <a href="index.php?action=failed_buildports&amp;build=<?=$build_name?>">Failed builds in this build</a><br />
 <input type="hidden" name="action" value="failed_buildports" />
 <input type="hidden" name="build" value="<?=$build_name?>" />
 Failed builds in this build for the maintainer <select name="maintainer">
 	<option></option>
 <?foreach($maintainers as $maintainer) {?>
 	<option><?=$maintainer?></option>
 <?}?>
 </select>
 <input type="submit" name="Go" value="Go" /><br />
 <a href="index.php">Back to homepage</a>
</p>
 </form>
    <p>
      <a href="http://validator.w3.org/check?uri=referer"><img
          src="http://www.w3.org/Icons/valid-xhtml10"
          alt="Valid XHTML 1.0!" height="31" width="88" 
	  style="border:0"/></a>
    </p>
</body>
</html>
