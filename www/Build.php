<?php

    require_once 'TinderObject.php';

    class Build extends TinderObject {

	function Build($argv = array()) {
	    $object_hash = array(
		Build_Id => "",
		Build_Name => "",
		Jail_Id => "",
		Ports_Tree_Id => "",
		Build_Description => ""
	    );

	    $this->TinderObject($object_hash, $argv);
	}

	function getId() {
	    return $this->Build_Id;
	}

	function getName() {
	    return $this->Build_Name;
	}

	function getJailId() {
	    return $this->Jail_Id;
	}

	function getPortsTreeId() {
	    return $this->Ports_Tree_Id;
	}

	function getDescription() {
	    return $this->Build_Description;
	}

	function setName($name) {
	    $this->Build_Name = $name;
	}

	function setJailId($id) {
	    $this->Jail_Id = $id;
	}

	function setPortsTreeId($id) {
	    $this->Ports_Tree_Id = $id;
	}

	function setDescription($descr) {
	    $this->Build_Description = $descr;
	}
    }
?>
