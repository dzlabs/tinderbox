<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/list_failure_reasons.tpl,v 1.6 2009/01/02 13:54:39 beat Exp $ //-->
<title><?php echo $tinderbox_name?></title>
<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
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

		<?php foreach($port_fail_reasons as $reason) {?>
			<tr>
				<td><a name="<?php echo $reason['tag']?>" href="javascript:history.back()"><?php echo $reason['tag']?></a></td>
				<td><?php echo $reason['descr']?></td>
				<td class="<?php echo "fail_reason_".$reason['type']?>"><?php echo $reason['type']?></td>
			</tr>
		<?php }?>
	</table>

<p>Local time: <?php echo $local_time?></p>
<p style="color:#FF0000;font-size:10px;"><?php echo $ui_elapsed_time?></p>
<p style="color:#FF0000;font-size:10px;"><?php echo $mem_info?></p>
<?php echo $display_login?>
<p><a href="index.php">Back to homepage</a></p>
</body>
</html>
