<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/footer.inc.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<?=$display_login?>
	</div>
	<div id="footer">
		<div class="left">
			<ul>
				<li><a href="index.php">home</a></li>
				<li><a href="javascript:history.back()">back</a></li>
				<li><a href="#top">top</a></li>
				<li>Localtime: <?=date('Y-m-d H:i:s')?></li>
			</ul>
		</div>
		<div class="right">
<? if (is_array($footer_legend)) { ?>
<? foreach($footer_legend as $css_class => $legend_title) { ?>
				<table>
					<tr>
						<td class="<?=$css_class?>" style="width:10px;"></td>
						<td><?=$legend_title?></td>
					</tr>
				</table>
<? }} ?>
		</div>
	</div>
</body>
</html>
