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
# $Id: showbuild.php,v 1.6 2004/03/03 18:18:00 pav Exp $
#

    require_once 'TinderboxDS.php';

    $ds = new TinderboxDS();

    $port = $ds->getPortById($id);
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title>GNOME 2 Packages For i386</title>
<link href="tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<?php
    if ($port) {
?>
<h1>GNOME 2 Packages for i386 - <?= $port->getName() ?></h1>
<?php
	echo "<p>\n";
	echo "Directory: " . $port->getDirectory() . "<br />\n";
	echo "Comment: " . $port->getComment() . "<br />\n";
	echo "Maintainer: " . $port->getMaintainer() . "<br />\n";
	echo "</p>\n";

	$builds = $ds->getBuildsOfPort($id);

	if ($builds) {

		?>
		<table>
		<tr>
		<th>Build</th>
		<th>Version</th>
		<th style="width: 20px">&nbsp;</th>
		<th>&nbsp;</th>
		<th>Last Build Attempt</th>
		<th>Last Successfull Build</th>
		</tr>
		<?php
		foreach ($builds as $build) {
			echo "<tr>\n";
			echo "<td><a href=\"showbuild.php?name=" . $build["Build_Name"] . "\">" . $build["Build_Name"] . "</a></td>\n";
			echo "<td>" . $build["Last_Built_Version"] . "</td>\n";
			if ($build["Last_Status"] == "SUCCESS") {
				echo "<td style=\"background-color: rgb(224,255,224)\">&nbsp;</td>\n";
				echo "<td><a href=\"" . $pkgdir . "/" . $build["Build_Name"] . "/All/" . $build["Last_Built_Version"] . ".tbz" . "\">package</a></td>\n";
			} elseif ($build["Last_Status"] == "FAIL") {
				echo "<td style=\"background-color: red\">&nbsp;</td>\n";
				echo "<td><a href=\"" . $errorlogdir . "/" . $build["Build_Name"] . "/" . $build["Last_Built_Version"] . ".log\">log</a></td>\n";
			} else { /* UNKNOWN */
				echo "<td style=\"background-color: grey\">&nbsp;</td>\n";
				echo "<td>&nbsp;</td>\n";
			}
			echo "<td>" . $port->prettyDatetime($build["Last_Built"]) . "</td>\n";
			echo "<td>" . $port->prettyDatetime($build["Last_Successful_Built"]) . "</td>\n";
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

</body>
</html>
