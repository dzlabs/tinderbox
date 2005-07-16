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
# $MCom: portstools/tinderbox/www/lastbuilds.php,v 1.21 2005/07/16 23:15:46 pav Exp $
#

    require_once 'TinderboxDS.php';

    $ds = new TinderboxDS();

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title><?= $tinderbox_name ?> - Latest Builds</title>
<link href="tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<?php
	$builds = $ds->getBuilds();

	$activeBuilds = array();
	if ($builds) {
		foreach ($builds as $build) {
			if (empty($showbuild) || $build->getName() == $showbuild) {
				if ($build->getBuildStatus() == "PORTBUILD") {
					$activeBuilds[] = $build;
				}
			}
		}
	}

	if (sizeof($activeBuilds) > 0) {
		?>
		<h1>Current Builds<?= ($showbuild ? " in $showbuild" : "" ) ?></h1>
		<table>
		<tr>
		<th>Build</th>
		<th>Port</th>
		</tr>
		<?php
		foreach ($activeBuilds as $build) {
			echo "<tr>\n";
			echo "<td><a href=\"showbuild.php?name=" . $build->getName() . "\">" . $build->getName() . "</a></td>\n";
			if ($build->getBuildCurrentPort()) {
				echo "<td>" . $build->getBuildCurrentPort() . "</td>\n";
			} else {
				echo "<td><i>preparing next build...</i></td>\n";
			}
			echo "</tr>\n";
		}
		?>
		</table>
		<?php
	}

	$queue = $ds->getQueue();

	if (sizeof($queue) > 0) {
		?>
		<h1>Queue</h1>
		<table>
		<tr>
		<th>Host</th>
		<th>Build</th>
		<th>Port</th>
		<th>Priority</th>
		</tr>
		<?php
		foreach ($queue as $item) {
			echo "<tr>\n";
			echo "<td>" . $item["Host_Name"] . "</td>\n";
			echo "<td><a href=\"showbuild.php?name=" . $item["Build_Id"] . "\">" . $item["Build_Name"] . "</a></td>\n";
			echo "<td>" . $item["Port_Directory"] . "</td>\n";
			echo "<td align=\"right\">" . $item["Priority"] . "</td>\n";
			echo "</tr>\n";
		}
		?>
		</table>
		<?php
	}

	?>
	<h1>Latest Builds<?= ($showbuild ? " in $showbuild" : "" ) ?></h1>
	<?php
	$builds = $ds->getBuildsDetailed(array("Build_Name" => $showbuild, "Last_Built" => 20));

	if ($builds) {

		?>
		<table>
		<tr>
		<th>Build</th>
		<th>Port Directory</th>
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
			echo "<td><a href=\"showport.php?id=" . $build["Port_Id"] . " \">" . $build["Port_Directory"] . "</a></td>\n";
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

    $ds->destroy();
?>

<p>Local time: <?= $ds->prettyDatetime(date("Y-m-d H:i:s")) ?></p>

<p><a href="index.php">Back to homepage</a></p>

</body>
</html>
