<?php

    require_once 'TinderObject.php';

    class Jail extends TinderObject {

	function Jail($argv = array()) {
	    $object_hash = array(
		Jail_Id => "",
		Jail_Name => "",
		Jail_Tag => "",
		Jail_Last_Built => "",
		Jail_Update_Cmd => "",
		Jail_Description => ""
	    );

	    $this->TinderObject($object_hash, $argv);
	}

	function getId() {
	    return $this->Jail_Id;
	}

	function getName() {
	    return $this->Jail_Name;
	}

	function getTag() {
	    return $this->Jail_Tag;
	}

	function getLastBuilt() {
	    return $this->Jail_Last_Built;
	}

	function getUpdateCmd() {
	    return $this->Jail_Update_Cmd;
	}

	function getDescription() {
	    return $this->Jail_Description;
	}

	function setName($name) {
	    $this->Jail_Name = $name;
	}

	function setTag($tag) {
	    $this->Jail_Tag = $tag;
	}

	function setLastBuilt($time) {
	    $this->Jail_Last_Built = $time;
	}

	function setUpdateCmd($cmd) {
	    $this->Jail_Update_Cmd = $cmd;
	}

	function setDescription($descr) {
	    $this->Jail_Description = $descr;
	}
    }
?>
