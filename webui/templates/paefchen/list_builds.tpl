<?
$topmenu = array(
	"Current And Latest Builds" 	=> "index.php?action=latest_buildports",
	"Failed builds in this build"	=> "index.php?action=failed_buildports",
	"All (really) Build Failures"	=> "index.php?action=bad_buildports"
);

$legend = array(
	"S = Number of ports built successfully",
	"U = Number of ports with unknown status",
	"F = Number of ports that failed to build",
	"D = Number of ports that were not built due to a dependency failure",
	"L = Number of ports with leftovers",
	"R = Number of ports to be remade",
	"T = Total"
);

include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/list_builds.tpl,v 1.2 2008/01/07 03:53:59 as Exp $ //-->
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
<div class="subcontent">
	<form method="get" action="index.php">
	<fieldset>
		<label>All Build Failures for the maintainer</label>
	
			<input type="hidden" name="action" value="failed_buildports" />
			<select name="maintainer">
				<option></option>
<?foreach($maintainers as $maintainer) {?>
				<option><?=$maintainer?></option>
<?}?>
			</select>
			<input type="submit" name="Go" value="Go" />
	</fieldset>
	</form>
</div>
<?
$footer_legend = array(
	'build_portbuild'	=> 'Building',
	'build_prepare'		=> 'Prepare'
);
include 'footer.inc.tpl'; 
?>
