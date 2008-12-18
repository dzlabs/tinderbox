<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/footer.inc.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<?php echo $display_login?>
	</div>
	<div id="footer">
		<div class="left">
			<ul>
				<li><a href="index.php">home</a></li>
				<li><a href="javascript:history.back()">back</a></li>
				<li><a href="#top">top</a></li>
				<li>Localtime: <?php echo date('Y-m-d H:i:s')?></li>
				<li><?php echo $ui_elapsed_time?></li>
			</ul>
		</div>
		<div class="right">
<?php if (is_array($footer_legend)) { ?>
<?php foreach($footer_legend as $css_class => $legend_title) { ?>
				<table>
					<tr>
						<td class="<?php echo $css_class?>" style="width:10px;"></td>
						<td><?php echo $legend_title?></td>
					</tr>
				</table>
<?php }} ?>
		</div>
	</div>
</body>
</html>
