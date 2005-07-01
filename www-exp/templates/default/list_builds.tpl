<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<!-- $MCom: portstools/tinderbox/www-exp/templates/default/list_builds.tpl,v 1.1 2005/07/01 18:09:38 oliver Exp $ //-->
<title><?=$tinderbox_name?></title>
<link href="<?=$templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1><?=$tinderbox_title?></h1>
<?if(!$no_list){?>
	<table>
		<tr>
			<th style="width: 20px">&nbsp;</th>
			<th>Build Name</th>
			<th>Build Description</th>
			<th>Failures</th>
			<th>Build Packages</th>
		</tr>

		<?foreach($data as $row) {?>
			<tr>
				<td class="<?=$row['status_field_class']?>">&nbsp;</td>
				<td><a href="index.php?action=list_buildports&amp;build=<?=$row['name']?>"><?=$row['name']?></a></td>
				<td><?=$row['description']?></td>
				<td align="center"><?=$row['failures']?></td>
				<?if($row['packagedir']){?>
					<td><a href="<?=$row['packagedir']?>">Package Directory</a></td>
				<?}else{?>
					<td><i>No packages for this build</i></td>
				<?}?>
			</tr>
		<?}?>

	</table>
<?}else{?>
	<p>There are no builds configured.</p>
<?}?>

<form method="get" action="index.php">
<p>
<a href="index.php?action=latest_buildports">Current And Latest Builds</a><br />
<a href="index.php?action=failed_buildports">All Build Failures</a><br />
<input type="hidden" name="action" value="failed_buildports" />
All Build Failures for the maintainer <select name="maintainer">
	<option></option>
<?foreach($maintainers as $maintainer) {?>
	<option><?=$maintainer?></option>
<?}?>
</select>
<input type="submit" name="Go" value="Go" />
</p>
</form>
    <p>
      <a href="http://validator.w3.org/check?uri=referer"><img
          src="http://www.w3.org/Icons/valid-xhtml10"
          alt="Valid XHTML 1.0!" height="31" width="88" 
	  style="border:0"/></a>
    </p>
</body>
</html>
