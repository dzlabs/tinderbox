<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
	<!-- $MCom: portstools/tinderbox/webui/templates/default/display_markup_log.tpl,v 1.3 2008/09/19 15:07:38 as Exp $ //-->
	<title><?php echo $tinderbox_name?></title>
	<link href="<?php echo $templatesuri?>/tinderstyle.css" rel="stylesheet" type="text/css" />
	<script type="text/javascript" src="<?php echo $templatesuri?>/tinderstyle.js"></script>
</head>
<body>
	<h1><?php echo $data['port_directory']?> log</h1>
	<p><a href="<?php echo $data['port_link_logfile']?>">raw log</a></p>

<?php foreach ($stats as $severity => $tags) { ?>
	<div>
		<label>
			<input type="checkbox" id="<?php echo $severity?>"<?php if ($displaystats[$severity]) echo ' checked="checked"'?> />
			<span class="<?php echo $severity?>"> <?php echo $severity?>s (<?php echo $counts[$severity]?>)</span>
		</label>
		<table class="log" id="<?php echo $severity?>_table"<?php if (! $displaystats[$severity]) echo ' style="display:none"'?>>
	<?php foreach ($tags as $tag => $lnrs) { ?>
			<tr>
				<th colspan="2" class="line"><?php echo $tag?> (<?php echo count($lnrs)?>)</th>
			</tr>
		<?php foreach ($lnrs as $lnr) { ?>
			<tr>
				<td class="num"><a href="#<?php echo $lnr?>"><?php echo $lnr?></a></td>
				<td class="line"><a href="#<?php echo $lnr?>" style="color: <?php echo $colors[$lnr]?>"><?php echo $lines[$lnr]?></a></td>
			</tr>
		<?php } ?>
	<?php } ?>
		</table>
	</div>
<?php } ?>

<div>
	<label><input type="checkbox" id="linenumber"<?php if ($displaystats['linenumber']) echo ' checked="checked"'?> /> show line numbers</label>
</div>

<table id="log_table">
	<tr id="l0">
		<th<?php if (! $displaystats['linenumber']) echo ' style="display:none"'?>>Nr</th>
		<th>Line</th>
	</tr>
<?php foreach ($lines as $lnr => $line){?>
	<tr id="l<?php echo $lnr?>">
		<td<?php if (! $displaystats['linenumber']) echo ' style="display:none"'?>><a href="#<?php echo $lnr?>"><?php echo $lnr?></a></td>
		<td style="color:<?php echo $colors[$lnr]?>"><a name="<?php echo $lnr?>"></a><?php echo $line?></td>
	</tr>
<?php }?>
</table> 

<script type= "text/javascript">
	/* <![CDATA[ */
	var log_colorlines = {error: {}, warning: {}, information: {}};
<?php foreach ($stats as $severity => $tags) {
	foreach ($tags as $tag => $lnrs) {
		foreach ($lnrs as $lnr) { ?>
	log_colorlines["<?php echo $severity?>"][<?php echo $lnr?>] = "<?php echo $colors[$lnr]?>";
<?php }}} ?>
	window.onload = log_ini;
	/* ]]> */
</script>
</body>
</html>
