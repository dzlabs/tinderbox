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
# $Id: index.php,v 1.19 2004/12/28 14:39:47 pav Exp $
#

    require_once 'TinderboxDS.php';

    $ds = new TinderboxDS();

    $builds = $ds->getAllBuilds();
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title><?= $tinderbox_name ?></title>
<link href="tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1><?= $tinderbox_title ?></h1>
<?php
    if (is_array($builds) && sizeof($builds) > 0) {
?>
<table>
<tr>
<th style="width: 20px">&nbsp;</th>
<th>Build Name</th>
<th>Build Description</th>
<th>Failures</th>
<th>Build Packages</th>
</tr>
<?php
	foreach ($builds as $build) {
	    $stats = $ds->getBuildStats($build->getId());

	    echo "<tr>\n";
	    if ($build->getBuildStatus() == "PORTBUILD") {
		echo "<td style=\"background-color: green\">&nbsp;</td>\n";
	    } elseif ($build->getBuildStatus() == "PREPARE") {
		echo "<td style=\"background-color: lightblue\">&nbsp;</td>\n";
	    } else {
		echo "<td>&nbsp;</td>\n";
	    }
	    echo "<td><a href=\"showbuild.php?name=" . $build->getName() . "\">" . $build->getName() . "</a></td>\n";
	    echo "<td>" . $build->getDescription() . "</td>\n";
	    if ($stats["fails"] > 0) {
		echo "<td align=\"center\">" . $stats["fails"] . "</td>\n";
	    } else {
		echo "<td>&nbsp;</td>\n";
	    }
	    echo "<td>";
	    if (is_dir($pkgdir . "/" . $build->getName())) {
		echo "<a href=\"$pkguri/" . $build->getName() . "\">Package Directory</a>";
	    }
	    else {
		echo "<i>No packages for this build</i>";
	    }
	    echo "</td>\n";
	    echo "</tr>\n";
	}

	echo "</table>\n";

    } else {
	echo "<p>There are no builds configured.</p>\n";
    }

    $ds->destroy();
?>

<p>
<a href="lastbuilds.php">Current And Latest Builds</a><br />
<a href="failures.php">All Build Failures</a><br />
</p>

</body>
</html>
