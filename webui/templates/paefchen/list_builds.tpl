<?
$topmenu = array(
	"Current And Latest Builds" 	=> "index.php?action=latest_buildports",
	"Failed builds in this build"	=> "index.php?action=failed_buildports",
	"All (really) Build Failures"	=> "index.php?action=bad_buildports"
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
			<th>
				<span title="success / unknown / fail / leftovers">
				S / U / F / L
				</span>
			</th>
			<th>Build Packages</th>
		</tr>

		<?foreach($data as $row) {?>
			<tr>
				<td class="<?=$row['status_field_class']?>">&nbsp;</td>
				<td><a href="index.php?action=list_buildports&amp;build=<?=$row['name']?>"><?=$row['name']?></a></td>
				<td><?=$row['description']?></td>
				<td align="center">
					<span title="success / unknown / fail / leftovers">
					<?=$row['results']['SUCCESS']?>
					/
					<?=$row['results']['UNKNOWN']?>
					/
					<?=$row['results']['FAIL']?>
					/
					<?=$row['results']['LEFTOVERS']?>
					</span>
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
