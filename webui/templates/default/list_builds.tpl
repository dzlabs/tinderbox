<?
$legend = array(
    "S = Number of ports built successfully",
    "U = Number of ports with unknown status",
    "F = Number of ports that failed to build",
    "D = Number of ports that were not built due to a dependency failure",
    "L = Number of ports with leftovers",
    "R = Number of ports to be remade",
    "T = Total"
);
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/list_builds.tpl,v 1.12 2008/09/07 13:44:37 beat Exp $ //-->
<title><?=$tinderbox_name?></title>
<link href="<?=$templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
<link rel="alternate" type="application/rss+xml" title="<?=$tinderbox_name?> (RSS)" href="index.php?action=latest_buildports_rss" />
</head>
<body>
<h1><?=$tinderbox_title?></h1>
<? if (is_array($legend) && count($legend) > 0) { ?>
	<div id="legend">
		<ul>
			<? foreach ($legend as $items) { ?>
				<li><?=$items?></li>
			<? } ?>
		</ul>
	</div>
<? } ?>
<?if(!$no_list){?>
	<table>
		<tr>
			<th style="width: 20px">&nbsp;</th>
			<th>Build Name</th>
			<th>Build Description</th>
			<th style="width: 25px"><span title="success"> S </span></th>
			<th style="width: 25px"><span title="unknown"> U </span></th>
			<th style="width: 25px"><span title="fail"> F </span></th>
			<th style="width: 25px"><span title="depend"> D </span></th>
			<th style="width: 25px"><span title="leftovers"> L </span></th>
			<th style="width: 25px"><span title="remake"> R </span></th>
			<th style="width: 25px"><span title="total"> T </span></th>
			<th>Build Packages</th>
		</tr>

		<?foreach($data as $row) {?>
			<tr>
				<td class="<?=$row['status_field_class']?>">&nbsp;</td>
				<td><a href="index.php?action=list_buildports&amp;build=<?=$row['name']?>"><?=$row['name']?></a></td>
				<td><?=$row['description']?></td>
				<td align="center">
					<?if ($row['results']['SUCCESS'] != '-') {?>
						<a href="index.php?action=buildports_by_reason&amp;build=<?=$row['name']?>&amp;reason=SUCCESS">
					<?}?>
					<span title="success"><?=$row['results']['SUCCESS']?></span>
					<?if ($row['results']['SUCCESS'] != '-') {?>
						</a>
					<?}?>
				</td>
				<td align="center">
					<?if ($row['results']['UNKNOWN'] != '-') {?>
						<a href="index.php?action=buildports_by_reason&amp;build=<?=$row['name']?>&amp;reason=UNKNOWN">
					<?}?>
					<span title="unknown"><?=$row['results']['UNKNOWN']?></span>
					<?if ($row['results']['UNKNOWN'] != '-') {?>
						</a>
					<?}?>
				</td>
				<td align="center">
					<?if ($row['results']['FAIL'] != '-') {?>
						<a href="index.php?action=failed_buildports&amp;build=<?=$row['name']?>">
					<?}?>
					<span title="fail"><?=$row['results']['FAIL']?></span>
					<?if ($row['results']['FAIL'] != '-') {?>
						</a>
					<?}?>
				</td>
				<td align="center">
					<?if ($row['results']['DEPEND'] != '-') {?>
						<a href="index.php?action=buildports_by_reason&amp;build=<?=$row['name']?>&amp;reason=DEPEND">
					<?}?>
					<span title="depend"><?=$row['results']['DEPEND']?></span>
					<?if ($row['results']['DEPEND'] != '-') {?>
						</a>
					<?}?>
				</td>
				<td align="center">
					<?if ($row['results']['LEFTOVERS'] != '-') {?>
						<a href="index.php?action=buildports_by_reason&amp;build=<?=$row['name']?>&amp;reason=LEFTOVERS">
					<?}?>
					<span title="leftovers"><?=$row['results']['LEFTOVERS']?></span>
					<?if ($row['results']['LEFTOVERS'] != '-') {?>
						</a>
					<?}?>
				</td>
				<td align="center"><span title="remake"><?=$row['results']['REMAKE']?></span></td>
				<td align="center">
					<?if ($row['results']['TOTAL'] != '-') {?>
						<a href="index.php?action=list_buildports&amp;build=<?=$row['name']?>">
					<?}?>
					<span title="total"><?=$row['results']['TOTAL']?></span>
					<?if ($row['results']['TOTAL'] != '-') {?>
						</a>
					<?}?>
				</td>
				<?if($row['packagedir']){?>
					<td><a href="<?=$row['packagedir']?>">Package Directory</a></td>
				<?}else{?>
					<td><i>No packages for this build</i></td>
				<?}?>
			</tr>
		<?}?>
	</table>
<?}else{?>
	<p>There are no builds configured.</p>
<?}?>

<form method="get" action="index.php">
<p>
<a href="index.php?action=latest_buildports">Current And Latest Builds</a><br />
<a href="index.php?action=failed_buildports">All Build Failures</a><br />
<a href="index.php?action=bad_buildports">All (really) Build Failures</a><br />
<input type="hidden" name="action" value="failed_buildports" />
All Build Failures for the maintainer <select name="maintainer">
	<option></option>
<?foreach($maintainers as $maintainer) {?>
	<option><?=$maintainer?></option>
<?}?>
</select>
<input type="submit" name="Go" value="Go" />
</p>
</form>
<?=$display_login?>
</body>
</html>
