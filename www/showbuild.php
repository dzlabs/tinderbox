<?php
#-
# Copyright (c) 2004 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $Id: showbuild.php,v 1.8 2004/03/03 20:13:54 pav Exp $
#

    require_once 'TinderboxDS.php';

    $ds = new TinderboxDS();

    $build = $ds->getBuildByName($name);
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title>GNOME 2 Packages For i386</title>
<link href="tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<?php
    if ($build) {
?>
<h1>GNOME 2 Packages for i386 - <?= $build->getName() ?></h1>
<?php
	echo "<p>\n";
	echo "Description: " . $build->getDescription() . "<br />\n";

	$jail = $ds->getJailById($build->getJailId());
	echo "System: FreeBSD " . $jail->getName() . " (" . $jail->getTag() . ") updated on " . $ds->prettyDatetime($jail->getLastBuilt()) . "<br />\n";

	$ports_tree = $ds->getPortsTreeById($build->getPortsTreeId());
	echo "Ports Tree: " . $ports_tree->getDescription() . "<br />\n";
	echo "</p>\n";

	$ports = $ds->getPortsForBuild($build);

	if ($ports) {

		?>
		<table>
		<tr>
		<th>Port Directory</th>
		<th>Maintainer</th>
		<th>Version</th>
		<th style="width: 20px">&nbsp;</th>
		<th>&nbsp;</th>
		<th>Last Build Attempt</th>
		<th>Last Successfull Build</th>
		</tr>
		<?php
		foreach ($ports as $port) {
			echo "<tr>\n";
			echo "<td><a href=\"showport.php?id=" . $port->getId() . "\">" . $port->getDirectory() . "</a></td>\n";
			echo "<td>" . $ds->prettyEmail($port->getMaintainer()) . "</td>\n";
			echo "<td>" . $port->getLastBuiltVersion() . "</td>\n";
			if ($port->getLastStatus() == "SUCCESS") {
				echo "<td style=\"background-color: rgb(224,255,224)\">&nbsp;</td>\n";
				echo "<td><a href=\"" . $pkgdir . "/" . $build->getName() . "/All/" . $port->getLastBuiltVersion() . $ds->getPackageSuffix($build->getJailId()) . "\">package</a></td>\n";
			} elseif ($port->getLastStatus() == "FAIL") {
				echo "<td style=\"background-color: red\">&nbsp;</td>\n";
				echo "<td><a href=\"" . $errorlogdir . "/" . $build->getName() . "/" . $port->getLastBuiltVersion() . ".log\">log</a></td>\n";
			} else { /* UNKNOWN */
				echo "<td style=\"background-color: grey\">&nbsp;</td>\n";
				echo "<td>&nbsp;</td>\n";
			}
			echo "<td>" . $ds->prettyDatetime($port->getLastBuilt()) . "</td>\n";
			echo "<td>" . $ds->prettyDatetime($port->getLastSuccessfulBuilt()) . "</td>\n";
			echo "</tr>\n";
		}
		echo "</table>\n";

	} else {

		echo "<p>No ports are being build.</p>\n";

	}

    } else {

	echo "<p>Invalid build name.</p>\n";

    }

    $ds->destroy();
?>

</body>
</html>
