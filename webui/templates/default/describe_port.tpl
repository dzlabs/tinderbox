<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/describe_port.tpl,v 1.2 2005/07/10 08:56:29 oliver Exp $ //-->
<title><?=$tinderbox_name?></title>
<link href="<?=$templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1><?=$tinderbox_title?> - <?=$port_name?></h1>
<?if(!$no_list){?>
	<table>
		<tr>
			<td>Directory</td>
			<td><?=$port_dir?> (
			<?for($i=0;$i<count($ports_trees_links);$i++) {?>
				<a href="<?=$ports_trees_links[$i]['cvsweb']?>/<?=$port_dir?>"><?=$ports_trees_links[$i]['name']?></a>
			<?}?>
			)</td>
		</tr>
		<tr>
			<td>Comment</td>
			<td><?=$port_comment?></td>
		</tr>
		<tr>
			<td>Maintainer</td>
			<td><a href="mailto:<?=$port_maintainer?>"><?=$port_maintainer?></a></td>
		</tr>
	</table>
	<p>&nbsp;</p>
	<table>
		<tr>
			<th>Build</th>
			<th>Version</th>
			<th style="width: 20px">&nbsp;</th>
			<th>&nbsp;</th>
			<th>Last Build Attempt</th>
			<th>Last Successful Build</th>
		</tr>
		<?foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=list_buildports&amp;build=<?=$row['build_name']?>"><?=$row['build_name']?></a></td>
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
	<p>Invalid port ID.</p>
<?}?>

<p>Local time: <?=$local_time?></p>
<?=$display_login?>
<p><a href="index.php">Back to homepage</a></p>
    <p>
      <a href="http://validator.w3.org/check?uri=referer"><img
          src="http://www.w3.org/Icons/valid-xhtml10"
          alt="Valid XHTML 1.0!" height="31" width="88" 
	  style="border:0"/></a>
    </p>
</body>
</html>
