<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/list_failure_reasons.tpl,v 1.4 2008/01/25 20:12:50 marcus Exp $ //-->
<title><?=$tinderbox_name?></title>
<link href="<?=$templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>

	<h1>
		Port Build Failure Reasons
	</h1>

<p><a href="index.php">Back to homepage</a> <br />
<a href="javascript:history.back()">back</a></p>

	<table>
		<tr>
			<th>Tag</th>
			<th>Description</th>
			<th>Type</th>
		</tr>

		<?foreach($port_fail_reasons as $reason) {?>
			<tr>
				<td><a name="<?=$reason['tag']?>" href="javascript:history.back()"><?=$reason['tag']?></a></td>
				<td><?=$reason['descr']?></td>
				<td class="<?="fail_reason_".$reason['type']?>"><?=$reason['type']?></td>
			</tr>
		<?}?>
	</table>

<p>Local time: <?=$local_time?></p>
<p style="color:#FF0000;font-size:10px;"><?=$ui_elapsed_time?></p>
<?=$display_login?>
<p><a href="index.php">Back to homepage</a></p>
</body>
</html>
