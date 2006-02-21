<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/user_admin.tpl,v 1.5 2006/02/21 16:24:56 ade Exp $ //-->
<title><?=$tinderbox_name?></title>
<link href="<?=$templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1><?=$tinderbox_title?> - User Administration</h1>

<?if($errors){?>
	<p style="color:#FF0000">
	<?foreach($errors as $error){?>
		<?=$error?><br />
	<?}?>
	</p>
<?}?>

<form method="post" action="index.php">
<?=$user_properties?>
<p>
<?if($add==true){?>
<input type="hidden" name="action" value="add_user" />
<input type="submit" name="action_user" value="add" />
<?}elseif($modify==true){?>
<input type="hidden" name="action" value="modify_user" />
<input type="submit" name="action_user" value="modify" />
<input type="submit" name="action_user" value="delete" />
<?}?>
</p>
</form>
<p><a href="index.php">Back to homepage</a></p>
<?=$display_login?>
</body>
</html>
