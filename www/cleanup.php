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
# $Id: cleanup.php,v 1.1 2004/11/07 14:08:23 pav Exp $
#

require_once 'TinderboxDS.php';

$ds = new TinderboxDS();

$builds = $ds->getBuilds();
foreach ($builds as $build) {
	echo $build->getName()."\n";
	$package_suffix = $ds->getPackageSuffix($build->getJailId());

	/* delete unreferenced log files */
	$dir_handle = opendir("/space/logs/".$build->getName());
	while ($file_name = readdir($dir_handle)) {
		if (ereg("\.log$", $file_name)) {
			$result = mysql_query("SELECT Build_Port_Id FROM build_ports WHERE Build_Id = '".$build->getId()."' AND Last_Built_Version = '".substr($file_name,0,-4)."'");
			if (mysql_num_rows($result) == 0) {
				echo "Deleting stale ".$build->getName()."/".$file_name."\n";
				unlink("/space/logs/".$build->getName()."/".$file_name);
			}
		}
	}
	closedir($dir_handle);

	/* delete database records of nonexistant packages */
	$ports = $ds->getPortsForBuild($build);
	foreach ($ports as $port) {
		if ($port->getLastBuiltVersion()) {
			$path= "/space/packages" . "/" . $build->getName() . "/All/" . $port->getLastBuiltVersion() . $package_suffix;
			if (!file_exists($path)) {
				echo "Removing database entry for nonexistent package ".$build->getName()."/".$port->getLastBuiltVersion()."\n";
				$q = "DELETE FROM build_ports WHERE Build_Id = '".$build->getId()."' AND Port_Id = '".$port->getId()."'";
				mysql_query($q);
			}
		}
	}
}

$ds->destroy();
?>
