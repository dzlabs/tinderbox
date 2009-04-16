<?php
$header_title = $data['port_directory'] . " log";
$topmenu = array(
	$data['port_directory']	=> "index.php?action=describe_port&amp;id=$id",
	'raw log'				=> $data['port_link_logfile']
);
include 'header.inc.tpl';
?>

<?php if ($errors) { ?>
	<p style="color:#FF0000">
	<?php foreach($errors as $error){ ?>
		<?php echo $error?><br />
	<?php } ?>
	</p>
<?php }else{?>

<?php foreach ($stats as $severity => $tags) { ?>
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
<?php } ?>

<div>
	<label><input type="checkbox" id="linenumber"<?php if ($displaystats['linenumber']) echo ' checked="checked"'?> /> show line numbers</label>
</div>

<table class="log" id="log_table">
	<tr id="l0">
		<th class="num"<?php if (! $displaystats['linenumber']) echo ' style="display:none"'?>>Nr</th>
		<th class="line">Line</th>
	</tr>
<?php foreach ($lines as $lnr => $line){?>
	<tr id="l<?php echo $lnr?>">
		<td class="num"<?php if (! $displaystats['linenumber']) echo ' style="display:none"'?>><a href="#<?php echo $lnr?>"><?php echo $lnr?></a></td>
		<td class="line" style="color:<?php echo $colors[$lnr]?>"><a name="<?php echo $lnr?>"></a><?php echo $line?></td>
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
<?php } ?>

<?php 
include 'footer.inc.tpl'; 
?>
