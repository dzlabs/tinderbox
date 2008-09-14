<?php
$header_title = 'User Administration';
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/user_admin.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<?php if($errors){?>
	<p style="color:#FF0000">
	<?php foreach($errors as $error){?>
		<?php echo $error?><br />
	<?php }?>
	</p>
<?php }?>
<form method="post" action="index.php">
<?php echo $user_properties?>
<?php echo $user_permissions?>

<div class="subcontent">
<?php if($add==true){?>
	<input type="hidden" name="action" value="add_user" />
	<input type="submit" name="action_user" value="add" />
<?php }elseif($modify==true){?>
	<input type="hidden" name="action" value="modify_user" />
	<input type="submit" name="action_user" value="modify" />
	<input type="submit" name="action_user" value="delete" />
<?php }?>
</div>
</form>

<?php  include 'footer.inc.tpl'; ?>
