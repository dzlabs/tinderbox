<?php

    require_once 'DB.php';
    require_once 'Port.php';
    require_once 'Build.php';
    require_once 'Jail.php';
    require_once 'PortsTree.php';
    require_once 'ds.inc';

    $objectMap = array(
	"Port" => "ports",
	"Jail" => "jails",
	"Build" => "builds",
	"PortsTree" => "ports_trees"
    );

    class TinderboxDS {
	var $db;
	var $error;

	function TinderboxDS() {
	    global $DB_HOST, $DB_NAME, $DB_USER, $DB_PASS;

	    $dsn = "mysql://$DB_USER:$DB_PASS@$DB_HOST/$DB_NAME";

	    $this->db = DB::connect($dsn);

	    if (DB::isError($this->db)) {
		die ("Tinderbox DS: Unable to initialize datastore: " . $this->db->getMessage() . "\n");
	    }

	    $this->db->setFetchMode(DB_FETCHMODE_ASSOC);
	}

	function getAllPorts() {
	    $ports = array();

	    $ports = $this->getPorts();

	    return $ports;
	}

	function getPortsForBuild($build) {
	    $ports = array();

	    $rc = $this->_doQueryHashRef("SELECT * FROM ports WHERE Port_Id IN (SELECT Port_Id FROM build_ports WHERE Build_Id=?)", $results, $build->getId());

	    if (!$rc) {
		return null;
	    }

	    $ports = $this->_newFromArray("Port", $results);

	    return $ports;
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

	function getPorts($params = array()) {
	    return $this->getObjects("Port", $params);
	}

	function getObjects($type, $params = array()) {
	    global $objectMap;

	    if (!isset($objectMap[$type])) {
		die("Uknown object type, $type\n");
	    }

	    $table = $objectMap[$type];
	    $condition = "";
	    $objects = array();

	    $values = array();
	    $conds = array();
	    foreach ($params as $param) {
		# Each parameter makes up and OR portion of a query.  Within
		# each parameter is a hash reference that make up the AND
		# portion of the query.
		$ands = array();
		foreach ($param as $andcond => $value) {
		    array_push($ands, "$andcond=?");
		    array_push($values, $value);
		}
		array_push($conds, "(" . (implode(" AND ", $ands)) . ")");
	    }

	    $condition = implode(" OR ", $conds);

	    $query = "";
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

	    $objects = $this->_newFromArray($type, $results);

	    return $objects;
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
	    $builds = array();

	    $builds = $this->getBuilds();

	    return $builds;
	}

	function getAllJails() {
	    $jails = array();

	    $jails = $this->getJails();

	    return $jails;
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
		$row = $res->numRows();
	    }
	    else {
		while($res->fetchRow()) {
		    $row++;
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
    }
?>
