<?php
#-
# Copyright (c) 2004-2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $MCom: portstools/tinderbox/www/showport.php,v 1.23 2005/06/28 05:47:56 adamw Exp $
#

    require_once 'TinderboxDS.php';

    $ds = new TinderboxDS();

    $port = $ds->getPortById($id);
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title><?= $tinderbox_name ?></title>
<link href="tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<?php
    if ($port) {
?>
<h1><?= $tinderbox_title ?> - <?= $port->getName() ?></h1>
<?php
	$builds = $ds->getBuildsDetailed(array("Port_Id" => $id));

	foreach ($builds as $build) {
		$ports_trees[$build["Ports_Tree_Name"]] = $build["Ports_Tree_CVSweb_URL"];
	}

	echo "<p>\n";
	if (sizeof($ports_trees) > 1) {
		foreach ($ports_trees as $pt_name => $pt_url) {
			$ports_trees_links[] = "<a href=\"" . $pt_url . $port->getDirectory() . "\">" . $pt_name . "</a>";
		}
		echo "Directory: " . $port->getDirectory() . " (" . implode($ports_trees_links, ", ") . ")<br />\n";
	} else {
		echo "Directory: <a href=\"" . array_pop($ports_trees) . $port->getDirectory() . "\">" . $port->getDirectory() . "</a><br />\n";
	}
	echo "Comment: " . $port->getComment() . "<br />\n";
	echo "Maintainer: <a href=\"mailto:" . $port->getMaintainer() . "\">" . $port->getMaintainer() . "</a><br />\n";
	echo "</p>\n";

	if ($builds) {

		?>
		<table>
		<tr>
		<th>Build</th>
		<th>Version</th>
		<th style="width: 20px">&nbsp;</th>
		<th>&nbsp;</th>
		<th>Last Build Attempt</th>
		<th>Last Successful Build</th>
		</tr>
		<?php
		foreach ($builds as $build) {
			echo "<tr>\n";
			echo "<td><a href=\"showbuild.php?name=" . $build["Build_Name"] . "\">" . $build["Build_Name"] . "</a></td>\n";
			echo "<td>" . $build["Last_Built_Version"] . "</td>\n";
			echo $ds->getStatusCell($build["Last_Status"], $build["Build_Name"], $build["Last_Built_Version"]);
			echo $ds->getLinksCell($build["Last_Status"], $build["Build_Name"], $build["Last_Built_Version"], $ds->getPackageSuffix($build["Jail_Id"]));
			echo "<td>" . $ds->prettyDatetime($build["Last_Built"]) . "</td>\n";
			echo "<td>" . $ds->prettyDatetime($build["Last_Successful_Built"]) . "</td>\n";
			echo "</tr>\n";
		}
		echo "</table>\n";

	} else {

		echo "<p>This port is not being built.</p>\n";

	}

    } else {

	echo "<p>Invalid port ID.</p>\n";

    }

    $ds->destroy();
?>

<p>Local time: <?= $ds->prettyDatetime(date("Y-m-d H:i:s")) ?></p>

<p><a href="index.php">Back to homepage</a></p>

</body>
</html>
