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
# $Id: index.php,v 1.3 2004/03/02 19:51:43 marcus Exp $
#

    require_once 'TinderboxDS.php';

    $pkgdir = '/packages';
    $ds = new TinderboxDS();

    $builds = $ds->getAllBuilds();
?>

<html>
<head>
<title>GNOME 2 Packages For i386</title>
</head>
<body bgcolor="#FFFFFF">
<h1>GNOME 2 Packages for i386</h1>
<?php
    if (is_array($builds)) {
?>
<table border="1" cellpadding="1" cellspacing="1">
<tr>
<th>Build Name</th>
<th>Build Description</th>
<th>Build Packages</th>
</tr>
<?php
	foreach ($builds as $build) {
	    echo "<tr>\n";
	    echo "<td>" . $build->getName() . "</td>\n";
	    echo "<td>" . $build->getDescription() . "</td>\n";
	    echo "<td>";
	    if (is_dir($pkgdir . "/" . $build->getName())) {
		echo "<a href=\"$pkgdir/" . $build->getName() . "\">Package Directory</a>";
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

</body>
</html>
