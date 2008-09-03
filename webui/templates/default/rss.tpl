<?='<'?>?xml version="1.0" encoding="ISO-8859-1"?>

<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/">
	<channel>
		<title><?=$tinderbox_title?></title>
		<link><?=$wwwrooturi?></link>
		<lastBuildDate><?=$lastBuildDate?></lastBuildDate>
		<generator><?=$tinderbox_name?></generator>
		<ttl>10</ttl>
<?foreach($data as $row) {?>
		<item>
			<title>[<?=$row['jail_name']?>] - <?=$row['port_directory']?> - <?=$row['port_last_status']?> - <?=str_replace(preg_replace('@^.+/@', '', $row['port_directory']).'-', '', $row['port_last_built_version'])?></title>
			<link><?=$row['port_link_logfile']?></link>
			<pubDate><?=$row['port_last_built']?></pubDate>
			<author><?=$row['build_name']?> => <?=$row['jail_name']?></author>
			<description><?=$row['port_directory']?> => <?=$row['port_last_status']?> [<?=$row['build_name']?>|<?=$row['jail_name']?>] -- <?=$row['port_link_logfile']?></description>
		</item>
<?}?>
	</channel>
</rss>
