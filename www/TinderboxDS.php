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
# $MCom: portstools/tinderbox/www/TinderboxDS.php,v 1.37 2005/09/05 04:20:25 ade Exp $
#

    require_once 'DB.php';
    require_once 'Port.php';
    require_once 'Build.php';
    require_once 'Jail.php';
    require_once 'PortsTree.php';
    require_once 'inc_ds.php';
    require_once 'inc_tinderbox.php';

    $objectMap = array(
	"Port" => "ports",
	"Jail" => "jails",
	"Build" => "builds",
	"PortsTree" => "ports_trees"
    );

    class TinderboxDS {
	var $db;
	var $error;
	var $packageSuffixCache; /* in use by getPackageSuffix() */

	function TinderboxDS() {
	    global $DB_HOST, $DB_DRIVER, $DB_NAME, $DB_USER, $DB_PASS;

	    # XXX: backwards compatibility
	    if ($DB_DRIVER == "")
		$DB_DRIVER = "mysql";

	    $dsn = "$DB_DRIVER://$DB_USER:$DB_PASS@$DB_HOST/$DB_NAME";

	    $this->db = DB::connect($dsn);

	    if (DB::isError($this->db)) {
		die ("Tinderbox DS: Unable to initialize datastore: " . $this->db->getMessage() . "\n");
	    }

	    $this->db->setFetchMode(DB_FETCHMODE_ASSOC);
	    $this->db->setOption('persistent', true);
	}

	function getAllPorts() {
	    return $ports = $this->getPorts();
	}

	function getPortsForBuild($build) {
	    $query = "SELECT ports.*,build_ports.Last_Built,build_ports.Last_Status,build_ports.Last_Successful_Built,Last_Built_Version FROM ports,build_ports WHERE ports.Port_Id = build_ports.Port_Id AND Build_Id=? ORDER BY Port_Directory";
	    $rc = $this->_doQueryHashRef($query, $results, $build->getId());

	    if (!$rc) {
		return null;
	    }

	    $ports = $this->_newFromArray("Port", $results);

	    return $ports;
	}

	function getBuildStats($build_id) {
	    $query = "SELECT SUM(IF(Last_Status = \"FAIL\", 1, 0)) AS fails FROM build_ports WHERE Build_Id = ?";
	    $rc = $this->_doQueryHashRef($query, $results, $build_id);
	    if (!$rc) return null;
	    return $results[0];
	}

	function getPortById($id) {
	    $results = $this->getPorts(array( 'Port_Id' => $id ));

	    if (is_null($results)) {
		return null;
	    }

	    return $results[0];
	}

	function getPortByDirectory($dir) {
	    $results = $this->getPorts(array( 'Port_Directory' => $dir ));

	    if (is_null($results)) {
		return null;
	    }

	    return $results[0];
	}

	function getBuildsDetailed($params) {
	    $query = "SELECT build_ports.*,builds.Build_Name,builds.Jail_Id,ports.Port_Directory,ports_trees.Ports_Tree_Name,ports_trees.Ports_Tree_CVSweb_URL ";
	    $query.= "FROM build_ports,builds,ports_trees,ports ";
	    $query.= "WHERE build_ports.Build_Id = builds.Build_Id AND builds.Ports_Tree_Id = ports_trees.Ports_Tree_Id AND build_ports.Port_Id = ports.Port_Id ";
	    if (is_array($params)) {
		foreach ($params as $key => $param) {
		    if (!empty($param)) {
			switch ($key) {
				case "Build_Name": $query.= "AND Build_Name = '" . $param . "' "; break;
				case "Port_Id": $query.= "AND build_ports.Port_Id = '" . $param . "' "; break;
				case "Last_Status": $query.= "AND Last_Status = '" . $param . "' "; break;
				case "Last_Built": $query.= "AND Last_Built IS NOT NULL ORDER BY Last_Built DESC LIMIT " . (int)$param; break;
			}
		    }
		}
	    }
	    $rc = $this->_doQueryHashRef($query, $results, array());
	    if (!$rc) return null;
	    return $results;
	}

	function getPorts($params = array()) {
	    return $this->getObjects("Port", $params);
	}

	function getObjects($type, $params = array()) {
	    global $objectMap;

	    if (!isset($objectMap[$type])) {
		die("Unknown object type, $type\n");
	    }

	    $table = $objectMap[$type];
	    $condition = "";

	    $values = array();
	    $conds = array();
	    foreach ($params as $field => $param) {
		# Each parameter makes up and OR portion of a query.  Within
		# each parameter can be a hash reference that make up the AND
		# portion of the query.
		if (is_array($param)) {
			$ands = array();
			foreach ($param as $andcond => $value) {
			    array_push($ands, "$andcond=?");
			    array_push($values, $value);
			}
			array_push($conds, "(" . (implode(" AND ", $ands)) . ")");
		} else {
			array_push($conds, "(" . $field . "=?)");
			array_push($values, $param);
		}
	    }

	    $condition = implode(" OR ", $conds);

	    if ($condition != "") {
		$query = "SELECT * FROM $table WHERE $condition";
	    }
	    else {
		$query = "SELECT * FROM $table";
	    }

	    $results = array();
	    $rc = $this->_doQueryHashRef($query, $results, $values);

	    if (!$rc) {
		return null;
	    }

	    return $this->_newFromArray($type, $results);
	}

	function getJailByName($name) {
	    $results = $this->getJails(array( 'Jail_Name' => $name ));

	    if (is_null($results)) {
		return null;
	    }

	    return $results[0];
	}

	function getJailById($id) {
	    $results = $this->getJails(array( 'Jail_Id' => $id ));

	    if (is_null($results)) {
		return null;
	    }

	    return $results[0];
	}

	function getBuildByName($name) {
	    $results = $this->getBuilds(array( 'Build_Name' => $name ));

	    if (is_null($results)) {
		return null;
	    }

	    return $results[0];
	}

	function getBuildById($id) {
	    $results = $this->getBuilds(array( 'Build_Id' => $id ));

	    if (is_null($results)) {
		return null;
	    }

	    return $results[0];
	}

	function getJailForBuild($build) {
	    $portstree = $this->getPortsTreeById($build->getPortsTreeId());

	    return $portstree;
	}

	function getPortsTreeByName($name) {
	     $results = $this->getPortsTrees(array( 'Ports_Tree_Name' => $name ));
	     if (is_null($results)) {
		 return null;
	     }

	     return $results[0];
	}

	function getPortsTreeById($id) {
	    $results = $this->getPortsTrees(array( 'Ports_Tree_Id' => $id ));

	    if (is_null($results)) {
	 	return null;
	    }

	    return $results[0];
	}

	function getBuilds($params = array()) {
	    return $this->getObjects("Build", $params);
	}

	function getJails($params = array()) {
	    return $this->getObjects("Jail", $params);
	}

	function getPortsTrees($params = array()) {
	    return $this->getObjects("PortsTree", $params);
	}

	function getAllBuilds() {
	    $builds = $this->getBuilds();

	    return $builds;
	}

	function getAllJails() {
	    $jails = $this->getJails();

	    return $jails;
        }

	function getQueue() {
	    $query = "SELECT Port_Directory,Priority,build_ports_queue.Build_Id,Build_Name,Host_Name,Status FROM build_ports_queue,hosts,builds ";
	    $query.= "WHERE build_ports_queue.Build_Id=builds.Build_ID AND build_ports_queue.Host_Id=hosts.Host_Id AND NOT (build_ports_queue.Status = 'SUCCESS') ";
	    $query.= "ORDER BY Priority,Build_Ports_Queue_Id";
	    $rc = $this->_doQueryHashRef($query, $results);
	    if (!$rc) {
		return null;
	    }
	    return $results;
	}

	function getError() {
	     return $this->error;
	}

	function _doQueryNumRows($query, $params = array()) {
	    $rows = 0;
	    $rc = $this->_doQuery($query, $params, $res);

	    if (!$rc) {
		return -1;
	    }

	    if ($res->numRows() > -1) {
		$rows = $res->numRows();
	    }
	    else {
		while($res->fetchRow()) {
		    $rows++;
		}
	    }

	    $res->free();

	    return $rows;
	}

	function _doQueryHashRef($query, &$results, $params = array()) {
	    $rc = $this->_doQuery($query, $params, $res);

	    if (!$rc) {
		$results = null;
		return 0;
	    }

	    $results = array();
	    while ($row = $res->fetchRow()) {
		array_push($results, $row);
	    }

	    $res->free();

	    return 1;
	}

	function _doQuery($query, $params, &$res) {
	    $sth = $this->db->prepare($query);

	    if (DB::isError($this->db)) {
		$this->error = $this->db->getMessage();
		return 0;
	    }

	    if (count($params)) {
		$_res = $this->db->execute($sth, $params);
	    }
	    else {
		$_res = $this->db->execute($sth);
	    }

	    if (DB::isError($_res)) {
		$this->error = $_res->getMessage();
		return 0;
	    }

	    if (!is_null($_res)) {
		$res = $_res;
	    }
	    else {
		$res->free();
	    }

	    $this->error = null;

	    return 1;
	}

	function _newFromArray($type, $arr) {
	    $objects = array();

	    foreach ($arr as $item) {
		eval('$obj = new $type($item);');
		if (!is_a($obj, $type)) {
		    return null;
		}
		array_push($objects, $obj);
	    }

	    return $objects;
	}

	function destroy() {
	    $this->db->disconnect();
	    $this->error = null;
	}

	function getPackageSuffix($jail_id) {
	    if (empty($jail_id)) return "";
	    /* Use caching to avoid a lot of SQL queries */
	    if ($this->packageSuffixCache[$jail_id]) {
		return $this->packageSuffixCache[$jail_id];
	    } else {
		$jail = $this->getJailById($jail_id);
		if (substr($jail->getName(), 0, 1) == "4") {
			$this->packageSuffixCache[$jail_id] = ".tgz";
			return ".tgz";
		} elseif (substr($jail->getName(), 0, 1) == "5") {
			$this->packageSuffixCache[$jail_id] = ".tbz";
			return ".tbz";
		} elseif (substr($jail->getName(), 0, 1) == "6") {
			$this->packageSuffixCache[$jail_id] = ".tbz";
			return ".tbz";
		} elseif (substr($jail->getName(), 0, 1) == "7") {
			$this->packageSuffixCache[$jail_id] = ".tbz";
			return ".tbz";
		}

	    }
	}

	/* formatting functions */

 	function prettyDatetime($input) {
		if (ereg("[0-9]{14}", $input)) {
			/* timestamp */
			return substr($input,0,4)."-".substr($input,4,2)."-".substr($input,6,2)." ".substr($input,8,2).":".substr($input,10,2).":".substr($input,12,2);
		} elseif (ereg("[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}", $input)) {
			/* datetime */
			if ($input == "0000-00-00 00:00:00") {
				return "";
			} else {
				return $input;
			}
		} else {
			return $input;
		}
	}

	function prettyEmail($input) {
		return eregi_replace("@FreeBSD.org", "", $input);
	}

	function getStatusCell($status, $build_name, $version) {
		global $logdir;

		if ($status == "SUCCESS") {
			echo "<td style=\"background-color: rgb(224,255,224)\">&nbsp;</td>\n";
		} elseif ($status == "LEFTOVERS") {
			echo "<td style=\"background-color: rgb(255,255,216); color: red; font-weight: bold; text-align: center\">L</td>\n";
		} elseif ($status == "BROKEN") {
			echo "<td style=\"background-color: rgb(224,255,224); color: red; font-weight: bold; text-align: center\">B</td>\n";
		} elseif ($status == "FAIL") {
			echo "<td style=\"background-color: red\">&nbsp;</td>\n";
		} else {
			echo "<td style=\"background-color: grey\">&nbsp;</td>\n";
		}
	}

	function getLinksCell($status, $build_name, $version, $package_extension) {
		global $loguri, $pkguri, $errorloguri;
		if ($status == "SUCCESS" || $status == "LEFTOVERS") {
			if ($version) {
				echo "<td>";
				echo "<a href=\"" . $loguri . "/" . $build_name . "/" . $version . ".log\">log</a> ";
				echo "<a href=\"" . $pkguri . "/" . $build_name . "/All/" . $version . $package_extension . "\">package</a>";
				echo "</td>\n";
			} else {
				echo "<td>&nbsp;</td>\n";
			}
		} elseif ($status == "BROKEN") {
			if ($version) {
				echo "<td><a href=\"" . $loguri . "/" . $build_name . "/" . $version . ".log\">log</a></td>\n";
			} else {
				echo "<td>&nbsp;</td>\n";
			}
		} elseif ($status == "FAIL") {
			if ($version) {
				echo "<td><a href=\"" . $errorloguri . "/" . $build_name . "/" . $version . ".log\">log</a></td>\n";
			} else {
				echo "<td>&nbsp;</td>\n";
			}
		} else {
			echo "<td>&nbsp;</td>\n";
		}
	}

   }
?>
