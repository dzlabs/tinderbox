<?php
$topmenu = array('back' => 'javascript:history.back()');
$header_title = 'Port Build Failure Reasons';
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/list_failure_reasons.tpl,v 1.4 2008/01/07 04:37:34 as Exp $ //-->
<table>
	<tr>
		<th>Tag</th>
		<th>Description</th>
		<th>Type</th>
	</tr>
<?php foreach($port_fail_reasons as $reason) {?>
	<tr>
		<td valign="top"><a id="<?php echo htmlspecialchars($reason['tag'])?>" href="javascript:history.back()"><?php echo htmlspecialchars($reason['tag'])?></a></td>
		<td style="white-space: normal;"><?php echo $reason['descr']?></td>
		<td valign="top" class="<?php echo "fail_reason_".$reason['type']?>"><?php echo $reason['type']?></td>
	</tr>
<?php }?>
</table>
<?php
$footer_legend = array(
	'port_dud'		=> 'Dud', 
	'port_depend'	=> 'Depend',
	'port_fail'		=> 'Fail',
);
include 'footer.inc.tpl'; ?>
