<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/describe_port.tpl,v 1.12 2011/12/01 18:16:46 beat Exp $ //-->
<title><?php echo $tinderbox_name?></title>
<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1><?php echo $tinderbox_title?> - <?php echo $port_name?></h1>
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
			<td>Directory</td>
			<td><?php echo $port_dir?> (
			<?php for($i=0;$i<count($ports_trees_links);$i++) {?>
				<a href="<?php echo $ports_trees_links[$i]['cvsweb']?>/<?php echo $port_dir?><?php echo $ports_trees_links[$i]['cvsweb_querystr']?>"><?php echo $ports_trees_links[$i]['name']?></a>
			<?php }?>
			)</td>
		</tr>
		<tr>
			<td>Comment</td>
			<td><?php echo $port_comment?></td>
		</tr>
		<tr>
			<td>Maintainer</td>
			<td><a href="mailto:<?php echo $port_maintainer?>"><?php echo $port_maintainer?></a></td>
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
			<th>Duration</th>
		</tr>
		<?php foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=list_buildports&amp;build=<?php echo $row['build_name']?>"><?php echo $row['build_name']?></a></td>
				<td><?php echo $row['port_last_built_version']?></td>
				<td class="<?php echo $row['status_field_class']?>"><?php echo $row['status_field_letter']?></td>
				<td>
					<?php if($row['port_link_logfile']){?>
						<a href="<?php echo $row['port_link_logfile']?>">log</a>
						<a href="index.php?action=display_markup_log&amp;build=<?php echo $row['build_name']?>&amp;id=<?php echo $row['port_id']?>">markup</a>
					<?php }?>
					<?php if($row['port_link_package']){?>
						<a href="<?php echo $row['port_link_package']?>">package</a>
					<?php }?>
					<?php if($is_logged_in) {?>
						<a href="index.php?action=add_tinderd_queue&amp;new_build_id=<?php echo $row['build_id']?>&amp;new_port_directory=<?php echo $row['port_directory']?>&amp;new_priority=10&amp;new_email_on_completion=0&amp;add_tinderd_queue=add&amp;filter_build_id=">requeue</a>
					<?php }?>
				</td>
				<td><?php echo $row['port_last_built']?></td>
				<td><?php echo $row['port_last_successful_built']?></td>
				<td><?php echo time_elapsed($row['port_last_run_duration'])?></td>
			</tr>
		<?php }?>
	</table>
<?php }?>

<p>Local time: <?php echo $local_time?></p>
<p style="color:#FF0000;font-size:10px;"><?php echo $ui_elapsed_time?></p>
<?php if(isset($load_average)){?>
	<p style="color:#FF0000;font-size:10px;">LA: <?php echo $load_average?></p>
<?php }?>
<p style="color:#FF0000;font-size:10px;"><?php echo $mem_info?></p>
<?php echo $display_login?>
<p><a href="index.php">Back to homepage</a></p>
</body>
</html>
