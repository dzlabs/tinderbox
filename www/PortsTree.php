<?php

    require_once 'TinderObject.php';

    class PortsTree extends TinderObject {

	function PortsTree($argv = array()) {
	    $object_hash = array(
		Ports_Tree_Id => "",
		Ports_Tree_Name => "",
		Ports_Tree_Description => "",
		Ports_Tree_Last_Built => "",
		Ports_Tree_Update_Cmd => ""
	    );

	    $this->TinderObject($object_hash, $argv);
	}

	function getId() {
	    return $this->Ports_Tree_Id;
	}

	function getName() {
	    return $this->Ports_Tree_Name;
	}

	function getDescription() {
	    return $this->Ports_Tree_Description;
	}

	function getLastBuilt() {
	    return $this->Ports_Tree_Last_Built;
	}

	function getUpdateCmd() {
	    return $this->Ports_Tree_Update_Cmd;
	}

	function setName($name) {
	    $this->Ports_Tree_Name = $name;
	}

	function setDescription($descr) {
	    $this->Ports_Tree_Description = $descr;
	}

	function setLastBuilt($time) {
	    $this->Ports_Tree_Last_Built = $time;
	}

	function setUpdateCmd($cmd) {
	    $this->Ports_Tree_Update_Cmd = $cmd;
	}
    }
?>
