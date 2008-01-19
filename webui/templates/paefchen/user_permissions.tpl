<table>
	<tr>
		<th>Build</th>
		<th>Add<br />Queue<br />Entries</th>
		<th>Modify<br />Own<br />Queue<br />Entries</th>
		<th>Delete<br />Own<br />Queue<br />Entries</th>
		<th>Modify<br />Other<br />Queue<br />Entries</th>
		<th>Delete<br />Other<br />Queue<br />Entries</th>
		<th>Allow<br />Priority<br />&lt; 5</th>
	</tr>

	<?if($www_admin){?>
		<?foreach($all_builds as $build) {?>
		<tr>		
			<td><?=$build['build_name']?></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$build['build_id']?>][PERM_ADD_QUEUE]"          <?if(isset($permission_object[$build['build_id']]['PERM_ADD_QUEUE'])){?>checked="checked"<?}?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$build['build_id']?>][PERM_MODIFY_OWN_QUEUE]"   <?if(isset($permission_object[$build['build_id']]['PERM_MODIFY_OWN_QUEUE'])){?>checked="checked"<?}?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$build['build_id']?>][PERM_DELETE_OWN_QUEUE]"   <?if(isset($permission_object[$build['build_id']]['PERM_DELETE_OWN_QUEUE'])){?>checked="checked"<?}?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$build['build_id']?>][PERM_MODIFY_OTHER_QUEUE]" <?if(isset($permission_object[$build['build_id']]['PERM_MODIFY_OTHER_QUEUE'])){?>checked="checked"<?}?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$build['build_id']?>][PERM_DELETE_OTHER_QUEUE]" <?if(isset($permission_object[$build['build_id']]['PERM_DELETE_OTHER_QUEUE'])){?>checked="checked"<?}?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$build['build_id']?>][PERM_PRIO_LOWER_5]"       <?if(isset($permission_object[$build['build_id']]['PERM_PRIO_LOWER_5'])){?>checked="checked"<?}?> /></td>
		</tr>
		<?}?>
	<?}else{?>
		<?foreach($all_builds as $build) {?>
		<tr>		
			<td><?=$build['build_name']?></td>
			<td align="center"><?if($permission_object[$build['build_id']]['PERM_ADD_QUEUE']){?>X<?}?></td>
			<td align="center"><?if($permission_object[$build['build_id']]['PERM_MODIFY_OWN_QUEUE']){?>X<?}?></td>
			<td align="center"><?if($permission_object[$build['build_id']]['PERM_DELETE_OWN_QUEUE']){?>X<?}?></td>
			<td align="center"><?if($permission_object[$build['build_id']]['PERM_MODIFY_OTHER_QUEUE']){?>X<?}?></td>
			<td align="center"><?if($permission_object[$build['build_id']]['PERM_DELETE_OTHER_QUEUE']){?>X<?}?></td>
			<td align="center"><?if($permission_object[$build['build_id']]['PERM_PRIO_LOWER_5']){?>X<?}?></td>
		</tr>
		<?}?>
	<?}?>

</table>
