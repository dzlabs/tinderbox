<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/www-exp/templates/default/user_admin.tpl,v 1.1 2005/07/10 07:39:19 oliver Exp $ //-->
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
<p><br /></p>
<?=$user_permissions?>
</p>
<p>
<?if($add==1){?>
<input type="hidden" name="action" value="add_user" />
<input type="submit" name="action_user" value="add" />
<?}elseif($modify==1){?>
<input type="hidden" name="action" value="modify_user" />
<input type="submit" name="action_user" value="modify" />
<input type="submit" name="action_user" value="delete" />
<?}?>
</p>
</form>
<p>
<a href="index.php">Back to homepage</a>

<?=$display_login?>
    <p>
      <a href="http://validator.w3.org/check?uri=referer"><img
          src="http://www.w3.org/Icons/valid-xhtml10"
          alt="Valid XHTML 1.0!" height="31" width="88" 
	  style="border:0"/></a>
    </p>
</body>
</html>
