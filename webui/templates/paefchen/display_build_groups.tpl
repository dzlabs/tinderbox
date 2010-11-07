<?php
$topmenu = array(
	"Current And Latest Builds" 	=> "index.php?action=latest_buildports",
	"Failed builds in this build"	=> "index.php?action=failed_buildports",
	"All Failures"					=> "index.php?action=bad_buildports"
);

include 'header.inc.tpl';
?>
<?php if(!$no_list){?>
	<label>Build Groups</label>
	<table>
		<tr>
			<th>Build Group Name</th>
			<th>Build Name</th>
		</tr>

		<?php foreach($data as $row) {?>
			<tr>
				<td>
					<?php echo $row['build_group_name']?>
				</td>
				<td>
					<?php echo $row['build_name']?>
				</td>
			</tr>
		<?php }?>

	</table>
<?php }else{?>
	<p>There are no build groups configured.</p>
<?php }?>
<?php if($is_logged_in) {?>
	<label>Add Build Group</label>
	<form method="post" action="index.php">
		<fieldset>
			<table>
				<input type="hidden" name="action" value="add_build_group" />
				<tr>
					<th>Build</th>
					<th>Build Group Name</th>
					<th>&nbsp;</th>
				</tr>
				<tr>
					<td>
						<select name="build_id">
							<?php foreach($builds as $build) {?>
								<option value="<?php echo $build['build_id']?>"><?php echo $build['build_name']?></option>
							<?php }?>
						</select>
					</td>
					<td><input type="text" size="20" name="build_group_name" /></td>
					<td colspan="3"><input type="submit" name="add_build_group" value="add" /></td>
				</tr>
			</table>
		</fieldset>
	</form>
<?php }?>
<?php
include 'footer.inc.tpl'; 
?>
