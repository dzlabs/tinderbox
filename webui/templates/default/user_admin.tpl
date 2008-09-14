<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/user_admin.tpl,v 1.7 2008/09/14 16:22:14 marcus Exp $ //-->
<title><?php echo $tinderbox_name?></title>
<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1><?php echo $tinderbox_title?> - User Administration</h1>

<?php if($errors){?>
	<p style="color:#FF0000">
	<?php foreach($errors as $error){?>
		<?php echo $error?><br />
	<?php }?>
	</p>
<?php }?>

<form method="post" action="index.php">
<?php echo $user_properties?>
<p><br /></p>
<?php echo $user_permissions?>
<p>
<?php if($add==true){?>
<input type="hidden" name="action" value="add_user" />
<input type="submit" name="action_user" value="add" />
<?php }elseif($modify==true){?>
<input type="hidden" name="action" value="modify_user" />
<input type="submit" name="action_user" value="modify" />
<input type="submit" name="action_user" value="delete" />
<?php }?>
</p>
</form>
<p><a href="index.php">Back to homepage</a></p>
<?php echo $display_login?>
</body>
</html>
