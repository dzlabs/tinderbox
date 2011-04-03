<?php
$topmenu = array(
	"Current and latest builds in this build" 	=> "index.php?action=latest_buildports&amp;build=$build_name",
	"Failed builds in this build"				=> "index.php?action=failed_buildports&amp;build=$build_name"
);
$header_title = $build_name;
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/list_buildports.tpl,v 1.2 2008/01/07 03:53:59 as Exp $ //-->
<?php if(!$errors){?>
<h1><?php echo $build_name?> » <?php echo $build_description?></h1>

<div class="description">
	<table>
		<tr>
			<th></th>
			<th>Name</th>
			<th>Updated</th>
		</tr>
		<tr>
			<th>System</th>
			<td>FreeBSD <?php echo $jail_name?> (<?php echo $jail_tag?>)</td>
			<td><?php echo $jail_lastbuilt?></td>
		</tr>
 		<tr>
  			<th>Ports Tree</th>
  			<td><?php echo $ports_tree_description?></td>
			<td><?php echo $ports_tree_lastbuilt?></td>
	 	</tr>
	</table>
</div>

<div class="subcontent">
	<table>
		<tr>
			<td>
				<form method="get" action="index.php">
					<table>
						<tr>
							<th>Failed builds in this build for the maintainer</th>
						</tr>
						<tr>
							<td>
 								<input type="hidden" name="action" value="failed_buildports" />
								<input type="hidden" name="build" value="<?php echo $build_name?>" />
								<select name="maintainer">
									<option></option>
									<?php foreach($maintainers as $maintainer) {?>
										<option><?php echo $maintainer?></option>
									<?php }?>
								</select>
								<input type="submit" name="Go" value="Go" />
							</td>
						</tr>
					</table>
				</form>
			</td>
			<td>
				<form method="get" action="index.php">
					<table>
						<tr>
							<th>Find ports by name</th>
						</tr>
						<tr>
							<td>
								<input type="hidden" name="action" value="list_buildports" />
								<input type="hidden" name="build" value="<?php echo $build_name?>" />
								<input type="text" name="search_port_name" value="<?php echo $search_port_name?>" />
								<input type="submit" name="Go" value="Go" />
							</td>
						</tr>
					</table>
				</form>
			</td>
		</tr>
	</table>
</div>
<?php }?>

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
		<td class="<?php if(!empty($reason))echo "fail_reason_".$port_fail_reasons[$reason]['type']?>">
		<?php $href=isset($port_fail_reasons[$reason]['link']) ? "index.php?action=display_failure_reasons&amp;failure_reason_tag=$reason#$reason" : "#"?>
		<a href="<?php echo $href?>" class="<?php if(!empty($reason))echo "fail_reason_".$port_fail_reasons[$reason]['type']?>" title="<?php if(!empty($reason))echo $port_fail_reasons[$reason]['descr']?>"><?php echo $reason?></a>
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

<?php if(!$errors){?>
<div class="subcontent">
	<form method="get" action="index.php">
	<table>
		<tr>
			<th>Failed builds in this build for the maintainer</th>
		</tr>
		<tr>
			<td>
 				<input type="hidden" name="action" value="failed_buildports" />
				<input type="hidden" name="build" value="<?php echo $build_name?>" />
				<select name="maintainer">
					<option></option>
<?php foreach($maintainers as $maintainer) {?>
					<option><?php echo $maintainer?></option>
<?php }?>
				</select>
				<input type="submit" name="Go" value="Go" /><br />
			</td>
		</tr>
	</table>
	</form>
</div>
<?php }?>

<?php
$footer_legend = array(
	'port_success'	=> 'Success',
	'port_default'	=> 'Default',
	'port_leftovers'=> 'Leftovers', # L
	'port_dud'		=> 'Dud', # D
	'port_depend'	=> 'Depend',
	'port_fail'		=> 'Fail',
);
include 'footer.inc.tpl';
?>
