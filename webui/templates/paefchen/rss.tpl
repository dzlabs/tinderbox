<?php echo '<'?>?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/rss.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ -->

<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/">
	<channel>
		<title><?php echo $tinderbox_title?></title>
		<link><?php echo $wwwrooturi?></link>
		<lastBuildDate><?php echo $lastBuildDate?></lastBuildDate>
		<generator><?php echo $tinderbox_name?></generator>
		<ttl>10</ttl>
<?php foreach($data as $row) {?>
		<item>
			<title>[<?php echo $row['jail_name']?>] - <?php echo $row['port_directory']?> - <?php echo $row['port_last_status']?> - <?php echo str_replace(preg_replace('@^.+/@', '', $row['port_directory']).'-', '', $row['port_last_built_version'])?></title>
			<link><?php echo $row['port_link_logfile']?></link>
			<pubDate><?php echo $row['port_last_built']?></pubDate>
			<author><?php echo $row['build_name']?> => <?php echo $row['jail_name']?></author>
			<description><?php echo $row['port_directory']?> => <?php echo $row['port_last_status']?> [<?php echo $row['build_name']?>|<?php echo $row['jail_name']?>] -- <?php echo $row['port_link_logfile']?></description>
		</item>
<?php }?>
	</channel>
</rss>
