<?php

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
?>
</table>

</body>
</html>
