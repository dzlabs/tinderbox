<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/webui/templates/default/please_login.tpl,v 1.2 2006/02/21 16:24:56 ade Exp $ //-->
<title><?=$tinderbox_name?></title>
<link href="<?=$templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1><?=$tinderbox_title?></h1>
<p style="color:#FF0000">Please login!</p>
<p><a href="javascript:history.back()">Back</a><br />
<a href="index.php">Back to homepage</a></p>
<?=$display_login?>
</body>
</html>
