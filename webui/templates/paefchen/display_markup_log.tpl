<?php
include 'header.inc.tpl';
?>
<form action="index.php">
	<p>
		<input type="hidden" name="action" value="display_markup_log" />
		<input type="hidden" name="build" value="<?php echo $build?>" />
		<input type="hidden" name="id" value="<?php echo $id?>" />
	</p>
	<table class="pattern">
		<tr>
			<td style="vertical-align:top">
				<table class="pattern">
					<tr>
						<td>
							<input type="checkbox" name="show_error" value="yes" onclick="this.form.submit()" <?php if($show_error=='yes'){?>checked<?php }?> />
						</td>
						<td style="color: red">
							Errors
						</td>
						<td>
							(<?php echo $counter['error']?>)
						</td>
					</tr>
					<?php foreach($patterns as $pattern){?>
						<?php if($pattern['counter']!=0&&$pattern['severity']=='error'){?>
							<tr>
								<td>
									<?php if($pattern['show']=='yes'){?>
										<input type="checkbox" name="pattern_id[]" value="<?php echo $pattern['id']?>" onclick="this.form.submit()" checked />
									<?php }else{?>
										<input type="checkbox" name="pattern_id[]" value="<?php echo $pattern['id']?>" onclick="this.form.submit()" />
									<?php }?>
								</td>
								<td>
									<?php echo $pattern['tag']?>
								</td>
								<td>
									<?php echo $pattern['counter']?>
								</td>
							</tr>
						<?php }?>
					<?php }?>
				</table>
			</td>
			<td style="vertical-align:top">
				<table class="pattern">
					<tr>
						<td>
							<input type="checkbox" name="show_warning" value="yes" onclick="this.form.submit()" <?php if($show_warning=='yes'){?>checked<?php }?> />
						</td>
						<td style="color: orange">
							Warnings
						</td>
						<td>
							(<?php echo $counter['warning']?>)
						</td>
					</tr>
					<?php foreach($patterns as $pattern){?>
						<?php if($pattern['counter']!=0&&$pattern['severity']=='warning'){?>
							<tr>
								<td>
									<?php if($pattern['show']=='yes'){?>
										<input type="checkbox" name="pattern_id[]" value="<?php echo $pattern['id']?>" onclick="this.form.submit()" checked />
									<?php }else{?>
										<input type="checkbox" name="pattern_id[]" value="<?php echo $pattern['id']?>" onclick="this.form.submit()" />
									<?php }?>
								</td>
								<td>
									<?php echo $pattern['tag']?>
								</td>
								<td>
									<?php echo $pattern['counter']?>
								</td>
							</tr>
						<?php }?>
					<?php }?>
				</table>
			</td>
			<td style="vertical-align:top">
				<table class="pattern">
					<tr>
						<td>
							<input type="checkbox" name="show_information" value="yes" onclick="this.form.submit()" <?php if($show_information=='yes'){?>checked<?php }?> />
						</td>
						<td style="color: blue">
							Information
						</td>
						<td>
							(<?php echo $counter['information']?>)
						</td>
					</tr>
					<?php foreach($patterns as $pattern){?>
						<?php if($pattern['counter']!=0&&$pattern['severity']=='information'){?>
							<tr>
								<td>
									<?php if($pattern['show']=='yes'){?>
										<input type="checkbox" name="pattern_id[]" value="<?php echo $pattern['id']?>" onclick="this.form.submit()" checked />
									<?php }else{?>
										<input type="checkbox" name="pattern_id[]" value="<?php echo $pattern['id']?>" onclick="this.form.submit()" />
									<?php }?>
								</td>
								<td>
									<?php echo $pattern['tag']?>
								</td>
								<td>
									<?php echo $pattern['counter']?>
								</td>
							</tr>
						<?php }?>
					<?php }?>
				<tr><td>&nbsp;</td></tr>
				</table>
			</td>
		</tr>
	</table>
	<hr />
	<table class="pattern">
		<tr>
			<td>
				<input type="checkbox" name="show_line_number" value="yes" onclick="this.form.submit()" <?php if($show_line_number=='yes'){?>checked<?php }?> />
			</td>
			<td>
				Show line numbers
			</td>
		</tr>
	</table>
</form>
<hr />
<table>
	<tr>
		<?php if($show_line_number=='yes'){?>
			<th>Nr</th>
		<?php }?>
		<th>Line</th>
	</tr>
	<?php for($i=0;$i<sizeof($result);$i++){?>
	<tr>
		<?php if($show_line_number=='yes'){?>
		<td>
			<a href="#<?php echo ($i+1)?>">
				<?php echo ($i+1)?>
			</a>
		</td>
		<?php }?>
		<td style="font-family: monospace; white-space: normal; empty-cells: show; <?php if($result[$i]['color']!='None'){?>color:<?php echo $result[$i]['color']?><?php }?>">
			<a name="<?php echo ($i+1)?>">
				<?php echo $result[$i]['line']?>
			</a>
		</td>
	</tr>
	<?php }?>
</table>
<?php
include 'footer.inc.tpl'; 
?>
