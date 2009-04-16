<?php
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
<!-- $MCom: portstools/tinderbox/webui/templates/default/list_builds.tpl,v 1.16 2009/04/16 15:41:47 beat Exp $ //-->
<title><?php echo $tinderbox_name?></title>
<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
<link rel="alternate" type="application/rss+xml" title="<?php echo $tinderbox_name?> (RSS)" href="index.php?action=latest_buildports_rss" />
</head>
<body>
<h1><?php echo $tinderbox_title?></h1>
<?php if (is_array($legend) && count($legend) > 0) { ?>
	<div id="legend">
		<ul>
			<?php foreach ($legend as $items) { ?>
				<li><?php echo $items?></li>
			<?php } ?>
		</ul>
	</div>
<?php } ?>
<?php if(!$no_list){?>
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

		<?php foreach($data as $row) {?>
			<tr>
				<td class="<?php echo $row['status_field_class']?>">&nbsp;</td>
				<td><a href="index.php?action=list_buildports&amp;build=<?php echo $row['name']?>"><?php echo $row['name']?></a></td>
				<td><?php echo $row['description']?></td>
				<td align="center">
					<?php if ($row['results']['SUCCESS'] != '-') {?>
						<a href="index.php?action=buildports_by_reason&amp;build=<?php echo $row['name']?>&amp;reason=SUCCESS">
					<?php }?>
					<span title="success"><?php echo $row['results']['SUCCESS']?></span>
					<?php if ($row['results']['SUCCESS'] != '-') {?>
						</a>
					<?php }?>
				</td>
				<td align="center">
					<?php if ($row['results']['UNKNOWN'] != '-') {?>
						<a href="index.php?action=buildports_by_reason&amp;build=<?php echo $row['name']?>&amp;reason=UNKNOWN">
					<?php }?>
					<span title="unknown"><?php echo $row['results']['UNKNOWN']?></span>
					<?php if ($row['results']['UNKNOWN'] != '-') {?>
						</a>
					<?php }?>
				</td>
				<td align="center">
					<?php if ($row['results']['FAIL'] != '-') {?>
						<a href="index.php?action=failed_buildports&amp;build=<?php echo $row['name']?>">
					<?php }?>
					<span title="fail"><?php echo $row['results']['FAIL']?></span>
					<?php if ($row['results']['FAIL'] != '-') {?>
						</a>
					<?php }?>
				</td>
				<td align="center">
					<?php if ($row['results']['DEPEND'] != '-') {?>
						<a href="index.php?action=buildports_by_reason&amp;build=<?php echo $row['name']?>&amp;reason=DEPEND">
					<?php }?>
					<span title="depend"><?php echo $row['results']['DEPEND']?></span>
					<?php if ($row['results']['DEPEND'] != '-') {?>
						</a>
					<?php }?>
				</td>
				<td align="center">
					<?php if ($row['results']['LEFTOVERS'] != '-') {?>
						<a href="index.php?action=buildports_by_reason&amp;build=<?php echo $row['name']?>&amp;reason=LEFTOVERS">
					<?php }?>
					<span title="leftovers"><?php echo $row['results']['LEFTOVERS']?></span>
					<?php if ($row['results']['LEFTOVERS'] != '-') {?>
						</a>
					<?php }?>
				</td>
				<td align="center"><span title="remake"><?php echo $row['results']['REMAKE']?></span></td>
				<td align="center">
					<?php if ($row['results']['TOTAL'] != '-') {?>
						<a href="index.php?action=list_buildports&amp;build=<?php echo $row['name']?>">
					<?php }?>
					<span title="total"><?php echo $row['results']['TOTAL']?></span>
					<?php if ($row['results']['TOTAL'] != '-') {?>
						</a>
					<?php }?>
				</td>
				<?php if($row['packagedir']){?>
					<td><a href="<?php echo $row['packagedir']?>">Package Directory</a></td>
				<?php }else{?>
					<td><i>No packages for this build</i></td>
				<?php }?>
			</tr>
		<?php }?>
	</table>
<?php }else{?>
	<p>There are no builds configured.</p>
<?php }?>

<form method="get" action="index.php">
<p>
<a href="index.php?action=latest_buildports">Current And Latest Builds</a><br />
<a href="index.php?action=failed_buildports">All Build Failures</a><br />
<a href="index.php?action=bad_buildports">All (really) Build Failures</a><br />
<input type="hidden" name="action" value="failed_buildports" />
All Build Failures for the maintainer <select name="maintainer">
	<option></option>
<?php foreach($maintainers as $maintainer) {?>
	<option><?php echo $maintainer?></option>
<?php }?>
</select>
<input type="submit" name="Go" value="Go" />
</p>
</form>
<p>
<form method="get" action="index.php">
Find ports by name
<input type="hidden" name="action" value="list_buildports" />
<select name="build">
<?php foreach($data as $row) {?>
	<option value="<?php echo $row['name']?>"><?php echo $row['name']?></option>
<?php }?>
</select>
<input type="text" name="search_port_name" value="<?php if(isset($search_port_name))echo $search_port_name?>" />
<input type="submit" name="Go" value="Go" />
</form>
</p>
<br />
<?php echo $display_login?>
</body>
</html>
