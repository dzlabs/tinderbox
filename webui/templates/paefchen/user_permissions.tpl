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

	<?php if($www_admin){?>
		<?php foreach($all_builds as $build) {?>
		<tr>		
			<td><?php echo $build['build_name']?></td>
			<td align="center"><input type="checkbox" name="permission_object[<?php echo $build['build_id']?>][PERM_ADD_QUEUE]"          <?php if(isset($permission_object[$build['build_id']]['PERM_ADD_QUEUE'])){?>checked="checked"<?php }?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?php echo $build['build_id']?>][PERM_MODIFY_OWN_QUEUE]"   <?php if(isset($permission_object[$build['build_id']]['PERM_MODIFY_OWN_QUEUE'])){?>checked="checked"<?php }?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?php echo $build['build_id']?>][PERM_DELETE_OWN_QUEUE]"   <?php if(isset($permission_object[$build['build_id']]['PERM_DELETE_OWN_QUEUE'])){?>checked="checked"<?php }?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?php echo $build['build_id']?>][PERM_MODIFY_OTHER_QUEUE]" <?php if(isset($permission_object[$build['build_id']]['PERM_MODIFY_OTHER_QUEUE'])){?>checked="checked"<?php }?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?php echo $build['build_id']?>][PERM_DELETE_OTHER_QUEUE]" <?php if(isset($permission_object[$build['build_id']]['PERM_DELETE_OTHER_QUEUE'])){?>checked="checked"<?php }?> /></td>
			<td align="center"><input type="checkbox" name="permission_object[<?php echo $build['build_id']?>][PERM_PRIO_LOWER_5]"       <?php if(isset($permission_object[$build['build_id']]['PERM_PRIO_LOWER_5'])){?>checked="checked"<?php }?> /></td>
		</tr>
		<?php }?>
	<?php }else{?>
		<?php foreach($all_builds as $build) {?>
		<tr>		
			<td><?php echo $build['build_name']?></td>
			<?php if(isset($permission_object[$build['build_id']]['PERM_ADD_QUEUE'])){?>
				<td align="center"><?php if($permission_object[$build['build_id']]['PERM_ADD_QUEUE']){?>X<?php }?></td>
			<?php }else{?>
				<td align="center">&nbsp;</td>
			<?php }?>
			<?php if(isset($permission_object[$build['build_id']]['PERM_MODIFY_OWN_QUEUE'])){?>
				<td align="center"><?php if($permission_object[$build['build_id']]['PERM_MODIFY_OWN_QUEUE']){?>X<?php }?></td>
			<?php }else{?>
				<td align="center">&nbsp;</td>
			<?php }?>
			<?php if(isset($permission_object[$build['build_id']]['PERM_DELETE_OWN_QUEUE'])){?>
				<td align="center"><?php if($permission_object[$build['build_id']]['PERM_DELETE_OWN_QUEUE']){?>X<?php }?></td>
			<?php }else{?>
				<td align="center">&nbsp;</td>
			<?php }?>
			<?php if(isset($permission_object[$build['build_id']]['PERM_MODIFY_OTHER_QUEUE'])){?>
				<td align="center"><?php if($permission_object[$build['build_id']]['PERM_MODIFY_OTHER_QUEUE']){?>X<?php }?></td>
			<?php }else{?>
				<td align="center">&nbsp;</td>
			<?php }?>
			<?php if(isset($permission_object[$build['build_id']]['PERM_DELETE_OTHER_QUEUE'])){?>
				<td align="center"><?php if($permission_object[$build['build_id']]['PERM_DELETE_OTHER_QUEUE']){?>X<?php }?></td>
			<?php }else{?>
				<td align="center">&nbsp;</td>
			<?php }?>
			<?php if(isset($permission_object[$build['build_id']]['PERM_PRIO_LOWER_5'])){?>
				<td align="center"><?php if($permission_object[$build['build_id']]['PERM_PRIO_LOWER_5']){?>X<?php }?></td>
			<?php }else{?>
				<td align="center">&nbsp;</td>
			<?php }?>
		</tr>
		<?php }?>
	<?php }?>

</table>
