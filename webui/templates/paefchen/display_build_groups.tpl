<?php
$topmenu = array(
	"Current And Latest Builds" 	=> "index.php?action=latest_buildports",
	"Failed builds in this build"	=> "index.php?action=failed_buildports",
	"All Failures"					=> "index.php?action=bad_buildports"
);

include 'header.inc.tpl';
?>
<?php if($errors){?>
        <p style="color:#FF0000">
        <?php foreach($errors as $error){?>
                <?php echo $error?><br />
        <?php }?>
        </p>
<?php } else {?>
<?php if(!$no_list){?>
	<label>Build Groups</label>
	<table>
		<tr>
			<th>Build Group Name</th>
			<th>Build Name</th>
			<th>&nbsp;</th>
		</tr>

		<?php foreach($data as $row) {?>
			<tr>
				<form method="post" action="index.php">
					<td>
						<?php echo $row['build_group_name']?>
					</td>
					<td>
						<?php echo $row['build_name']?>
					</td>
					<td>
						<input type="hidden" name="action" value="delete_build_group" />
						<input type="hidden" name="build_group_name" value="<?php echo $row['build_group_name']?>" />
						<input type="hidden" name="build_name" value="<?php echo $row['build_name']?>" />
						<input type="submit" name="delete_build_group" value="delete" />
					</td>
				</form>
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
<?php }?>
<?php
include 'footer.inc.tpl'; 
?>
