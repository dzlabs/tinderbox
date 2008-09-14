<?php
if (preg_match('@<!-- (\w+):(\w+);(\w+):(\d*);(\w+):(\d*) //-->@', $display_login, $match)) {
	list(,, $user_name,, $user_id,, $is_www_admin) = $match;
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/header.inc.tpl,v 1.3 2008/01/07 03:53:59 as Exp $ //-->
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
	<title><?php echo $tinderbox_name?><?php  if (! empty($header_title)) print " - ".$header_title; ?></title>
	<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
	<link rel="alternate" type="application/rss+xml" title="<?php echo $tinderbox_name?> (RSS)" href="index.php?action=latest_buildports_rss" />
</head>
<body>
	<div id="header">
		<div class="left">
			<h1><a href="index.php"><?php echo $tinderbox_title?></a><?php  if (! empty($header_title)) print " - ".$header_title; ?></h1>
		</div>
		<div class="right">
		<?php  if (! empty($user_name)) { ?>
			<h1>Welcome <?php echo $user_name?>!</h1>
		<?php  } ?>
		</div>
	</div>
	<div id="topmenu">
		<a id="top"></a>
		<div class="left">
<?php  if (is_array($topmenu) && count($topmenu) > 0) { ?>
			<ul>
	<?php  foreach ($topmenu as $menu_title => $menu_url) { ?>
				<li><a href="<?php echo $menu_url?>"><?php echo $menu_title?></a></li>
	<?php  } ?>
			</ul>
<?php  } ?>
		</div>
		<div class="right">
<?php  if (! empty($user_name)) { ?>
			<form method="post" action="index.php">
			<ul>
				<li><a href="index.php?action=list_tinderd_queue">Queue</a></li>
	<?php  if ($is_www_admin == 1) { ?>
				<li><a href="index.php?action=config">Config</a></li>
				<li><a href="index.php?action=display_add_user">Add User</a></li>
	<?php  } ?>
				<li><a href="index.php?action=display_modify_user&amp;modify_user_id=<?php echo $user_id?>">Modify Me</a></li>
				<li><input type="submit" name="do_logout" value="Logout" /></li>
			</ul>	
			</form>
<?php  } ?>
		</div>
	</div>
	<?php  if (is_array($legend) && count($legend) > 0) { ?>
	<div id="legend">
		<ul>
			<?php  foreach ($legend as $items) { ?>
				<li><?php echo $items?></li>
	<?php  } ?>
		</ul>
	</div>
	<?php  } ?>
	<div id="content">

