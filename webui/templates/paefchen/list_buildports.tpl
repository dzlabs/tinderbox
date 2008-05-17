<?
$topmenu = array(
	"Current and latest builds in this build" 	=> "index.php?action=latest_buildports&amp;build=$build_name",
	"Failed builds in this build"				=> "index.php?action=failed_buildports&amp;build=$build_name"
);
$header_title = $build_name;
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/list_buildports.tpl,v 1.2 2008/01/07 03:53:59 as Exp $ //-->
<h1><?=$build_name?> » <?=$build_description?></h1>
<div class="description">
	<table>
		<tr>
			<th></th>
			<th>Name</th>
			<th>Updated</th>
		</tr>
		<tr>
			<th>System</th>
			<td>FreeBSD <?=$jail_name?> (<?=$jail_tag?>)</td>
			<td><?=$jail_lastbuilt?></td>
		</tr>
 		<tr>
  			<th>Ports Tree</th>
  			<td><?=$ports_tree_description?></td>
			<td><?=$ports_tree_lastbuilt?></td>
	 	</tr>
	</table>
</div>

<div class="subcontent">
	<form method="get" action="index.php">
	<table>
		<tr>
			<th>Failed builds in this build for the maintainer</th>
		</tr>
		<tr>
			<td>
 				<input type="hidden" name="action" value="failed_buildports" />
				<input type="hidden" name="build" value="<?=$build_name?>" />
				<select name="maintainer">
					<option></option>
<?foreach($maintainers as $maintainer) {?>
					<option><?=$maintainer?></option>
<?}?>
				</select>
				<input type="submit" name="Go" value="Go" />
			</td>
		</tr>
	</table>
	</form>
</div>

<?if(!$no_list){?>
<table>
	<tr>
		<th>
			<a href="<?= build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "port_directory") ?>">Port Directory</a>
		</th>
		<th>
			<a href="<?= build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "port_maintainer") ?>">Maintainer</a>
		</th>
		<th>
			<a href="<?= build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "last_built_version") ?>">Version</a>
		</th>
		<th style="width: 20px">&nbsp;</th>
		<th>
			<a href="<?= build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "last_fail_reason") ?>">Reason</a>
		</th>
		<th>&nbsp;</th>
		<th>
			<a href="<?= build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "last_built") ?>">Last Build Attempt</a>
		</th>
		<th>
			<a href="<?= build_query_string($_SERVER['PHP_SELF'], $querystring, "sort", "last_successful_built") ?>">Last Successful Build</a>
		</th>
	</tr>
	<?foreach($data as $row) {?>
	<tr>
		<td><a href="index.php?action=describe_port&amp;id=<?=$row['port_id']?>"><?=$row['port_directory']?></a></td>
		<td><?=$row['port_maintainer']?></td>
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
<p>Total: <?=count($data)?></p>
<?}else{?>
<p>No ports are being built.</p>
<?}?>

<div class="subcontent">
	<form method="get" action="index.php">
	<table>
		<tr>
			<th>Failed builds in this build for the maintainer</th>
		</tr>
		<tr>
			<td>
 				<input type="hidden" name="action" value="failed_buildports" />
				<input type="hidden" name="build" value="<?=$build_name?>" />
				<select name="maintainer">
					<option></option>
<?foreach($maintainers as $maintainer) {?>
					<option><?=$maintainer?></option>
<?}?>
				</select>
				<input type="submit" name="Go" value="Go" /><br />
			</td>
		</tr>
	</table>
	</form>
</div>
<?
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
