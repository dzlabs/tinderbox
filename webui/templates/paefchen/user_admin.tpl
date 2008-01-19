<?
$header_title = 'User Administration';
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/user_admin.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<?if($errors){?>
	<p style="color:#FF0000">
	<?foreach($errors as $error){?>
		<?=$error?><br />
	<?}?>
	</p>
<?}?>
<form method="post" action="index.php">
<?=$user_properties?>
<?=$user_permissions?>

<div class="subcontent">
<?if($add==true){?>
	<input type="hidden" name="action" value="add_user" />
	<input type="submit" name="action_user" value="add" />
<?}elseif($modify==true){?>
	<input type="hidden" name="action" value="modify_user" />
	<input type="submit" name="action_user" value="modify" />
	<input type="submit" name="action_user" value="delete" />
<?}?>
</div>
</form>

<? include 'footer.inc.tpl'; ?>
