<table>
	<tr>
		<th>Host</th>
		<th>Build</th>
		<th>Add<br />Queue<br />Entries</th>
		<th>Modify<br />Own<br />Queue<br />Entries</th>
		<th>Delete<br />Own<br />Queue<br />Entries</th>
		<th>Modify<br />Other<br />Queue<br />Entries</th>
		<th>Delete<br />Other<br />Queue<br />Entries</th>
		<th>Allow<br />Priority<br />&lt; 5</th>
	</tr>

<?foreach($all_hosts as $host) {?>
	<tr>
		<td rowspan="<?=count($all_builds)+1?>"><?=$host['host_name']?></td>
	</tr>		
	<?if($www_admin){?>
		<?foreach($all_builds as $build) {?>
		<tr>		
			<td><?=$build['build_name']?></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$host['host_id']?>][<?=$build['build_id']?>][PERM_ADD_QUEUE]"          <?if(isset($permission_object[$host['host_id']][$build['build_id']]['PERM_ADD_QUEUE'])){?>checked="checked"<?}?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$host['host_id']?>][<?=$build['build_id']?>][PERM_MODIFY_OWN_QUEUE]"   <?if(isset($permission_object[$host['host_id']][$build['build_id']]['PERM_MODIFY_OWN_QUEUE'])){?>checked="checked"<?}?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$host['host_id']?>][<?=$build['build_id']?>][PERM_DELETE_OWN_QUEUE]"   <?if(isset($permission_object[$host['host_id']][$build['build_id']]['PERM_DELETE_OWN_QUEUE'])){?>checked="checked"<?}?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$host['host_id']?>][<?=$build['build_id']?>][PERM_MODIFY_OTHER_QUEUE]" <?if(isset($permission_object[$host['host_id']][$build['build_id']]['PERM_MODIFY_OTHER_QUEUE'])){?>checked="checked"<?}?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$host['host_id']?>][<?=$build['build_id']?>][PERM_DELETE_OTHER_QUEUE]" <?if(isset($permission_object[$host['host_id']][$build['build_id']]['PERM_DELETE_OTHER_QUEUE'])){?>checked="checked"<?}?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?=$host['host_id']?>][<?=$build['build_id']?>][PERM_PRIO_LOWER_5]"       <?if(isset($permission_object[$host['host_id']][$build['build_id']]['PERM_PRIO_LOWER_5'])){?>checked="checked"<?}?> /></td>
		</tr>
		<?}?>
	<?}else{?>
		<?foreach($all_builds as $build) {?>
		<tr>		
			<td><?=$build['build_name']?></td>
			<td align="center"><?if($permission_object[$host['host_id']][$build['build_id']]['PERM_ADD_QUEUE']){?>X<?}?></td>
			<td align="center"><?if($permission_object[$host['host_id']][$build['build_id']]['PERM_MODIFY_OWN_QUEUE']){?>X<?}?></td>
			<td align="center"><?if($permission_object[$host['host_id']][$build['build_id']]['PERM_DELETE_OWN_QUEUE']){?>X<?}?></td>
			<td align="center"><?if($permission_object[$host['host_id']][$build['build_id']]['PERM_MODIFY_OTHER_QUEUE']){?>X<?}?></td>
			<td align="center"><?if($permission_object[$host['host_id']][$build['build_id']]['PERM_DELETE_OTHER_QUEUE']){?>X<?}?></td>
			<td align="center"><?if($permission_object[$host['host_id']][$build['build_id']]['PERM_PRIO_LOWER_5']){?>X<?}?></td>
		</tr>
		<?}?>
	<?}?>
<?}?>
</table>
