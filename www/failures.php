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
# $MCom: portstools/tinderbox/www/failures.php,v 1.8 2005/10/10 23:30:15 ade Exp $
#

    require_once 'TinderboxDS.php';

    $ds = new TinderboxDS();

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title><?= $tinderbox_name ?> - All Build Failures</title>
<link href="tinderstyle.css" rel="stylesheet" type="text/css" />
</head>
<body>
<h1>All Build Failures</h1>
	<?php
	$builds = $ds->getBuildsDetailed(array("last_status" => "FAIL"));

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
			echo "<td><a href=\"showbuild.php?name=" . $build["build_name"] . "\">" . $build["build_name"] . "</a></td>\n";
			echo "<td><a href=\"showport.php?id=" . $build["port_id"] . " \">" . $build["port_directory"] . "</a></td>\n";
			echo "<td>" . $build["last_built_version"] . "</td>\n";
			echo "<td style=\"background-color: red\">&nbsp;</td>\n";
			echo "<td><a href=\"" . $errorloguri . "/" . $build["build_name"] . "/" . $build["last_built_version"] . ".log\">log</a></td>\n";
			echo "<td>" . $ds->prettyDatetime($build["last_built"]) . "</td>\n";
			echo "<td>" . $ds->prettyDatetime($build["last_successful_built"]) . "</td>\n";
			echo "</tr>\n";
		}
		echo "</table>\n";

	} else {

		echo "<p>There are no build failures at this moment.</p>\n";

	}

    $ds->destroy();
?>

<p>Local time: <?= $ds->prettyDatetime(date("Y-m-d H:i:s")) ?></p>

<p><a href="index.php">Back to homepage</a></p>

</body>
</html>
