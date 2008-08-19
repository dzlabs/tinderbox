<?
$header_title = 'Tinderd Administration';
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/list_tinderd_queue.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<div class="subcontent">
	<form method="get" action="index.php">
	<input type="hidden" name="action" value="list_tinderd_queue" />
	<table>
		<tr>
			<th>Build</th>
			<td>
				<select name="filter_build_id">
					<option></option>
<?foreach($all_builds as $build) {?>
					<option value="<?=$build['build_id']?>" <?if ($build_id == $build['build_id']) {?>selected="selected"<?}?> ><?=$build['build_name']?></option>
<?}?>
				</select>
				<input type="submit" name="display" value="display" /> 
			</td>
		</tr>
	</table>
	</form>
</div>

<?if($errors){?>
	<p style="color:#FF0000">
	<?foreach($errors as $error){?>
		<?=$error?><br />
	<?}?>
	</p>
<?}?>

<table>
	<tr>
		<th>Build</th>
		<th>Priority</th>
		<th>Port Directory</th>
		<th>User</th>
		<th style="width: 20px">&nbsp;</th>
		<th>Email On Completion</th>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
	</tr>

<?if(!$no_list){?>

		<?foreach($entries as $row) {?>
			<form method="post" action="index.php">
			<input type="hidden" name="action" value="change_tinderd_queue" />
			<input type="hidden" name="entry_id" value="<?=$row['entry_id']?>" />
			<input type="hidden" name="filter_build_id" value="<?=$build_id?>" />
			<tr>
				<td>
					<?if($row['modify'] == 1){?>
						<select name="build_id">
							<?foreach($all_builds as $build) {?>
								<option value="<?=$build['build_id']?>" <?if ($row['build'] == $build['build_name']) {?>selected<?}?> ><?=$build['build_name']?></option>
							<?}?>
						</select>
					<?}else{?>
						<?=$row['build']?>
					<?}?>
				</td>
				<td>
					<?if($row['modify'] == 1){?>
						<select name="priority">
							<?foreach($row['all_prio'] as $prio) {?>
								<option value="<?=$prio?>" <?if ($row['priority'] == $prio) {?>selected<?}?> ><?=$prio?></option>
							<?}?>
						</select>
					<?}else{?>
						<?=$row['priority']?>
					<?}?>
				</td>
				<td><?=$row['directory']?></td>
				<td><?=$row['user']?></td>
				<td class="<?=$row['status_field_class']?>">&nbsp;</td>
				<td align="center">
					<?if($row['modify'] == 1){?>
						<input type="checkbox" name="email_on_completion" value="1" <?if($row['email_on_completion'] == 1 ) {?>checked="checked"<?}?> />
					<?}else{?>
						<?if($row['email_on_completion'] == 1 ) {?>X"<?}?>
					<?}?>
				</td>
				<td>
					<?if($row['modify'] == 1){?>
						<input type="submit" name="change_tinderd_queue" value="save" />
					<?}?>
				</td>
				<td>
					<?if($row['delete'] == 1){?>
						<input type="submit" name="change_tinderd_queue" value="delete" />
					<?}?>
				</td>
				<td>
					<?if($row['modify'] == 1){?>
						<input type="submit" name="change_tinderd_queue" value="reset status" />
					<?}?>
				</td>
			</tr>
			</form>
		<?}?>
<?}?>
			<form method="post" action="index.php">
			<input type="hidden" name="action" value="add_tinderd_queue" />
			<input type="hidden" name="entry_id" value="<?=$row['entry_id']?>" />
			<input type="hidden" name="filter_build_id" value="<?=$build_id?>" />
			<tr>
				<td>
					<select name="new_build_id">
						<?foreach($all_builds as $build) {?>
							<option value="<?=$build['build_id']?>" <?if ($new_build_id == $build['build_id']) {?>selected<?}?> ><?=$build['build_name']?></option>
						<?}?>
					</select>
				</td>
				<td>
					<select name="new_priority">
						<?foreach($all_prio as $prio) {?>
							<option value="<?=$prio?>" <?if ($new_priority == $prio) {?>selected<?}?> ><?=$prio?></option>
						<?}?>
					</select>
				</td>
				<td><input type="text" size="20" name="new_port_directory" value="<?=$new_port_directory?>" /></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td align="center">
					<input type="checkbox" name="new_email_on_completion" value="1" <?if($new_email_on_completion == 1 ) {?>checked="checked"<?}?> />
				</td>
				<td colspan="3"><input type="submit" name="add_tinderd_queue" value="add" /></td>
			</tr>
			</form>
	</table>
<? include('footer.inc.tpl'); ?>
