<?php

    require_once 'TinderObject.php';

    class Port extends TinderObject {

	function Port($argv = array()) {
	    $object_hash = array(
		Port_Id => "",
		Port_Name => "",
		Port_Directory => "",
		Port_Comment => ""
	    );

	    $this->TinderObject($object_hash, $argv);
	}

	function getId() {
	    return $this->Port_Id;
	}

	function getName() {
	    return $this->Port_Name;
	}

	function getDirectory() {
	    return $this->Port_Directory;
	}

	function getComment() {
	    return $this->Port_Comment;
	}

	function setName($name) {
	    $this->Port_Name = $name;
	}

	function setDirectory($dir) {
	    $this->Port_Directory = $dir;
	}

	function setComment($comment) {
	    $this->Port_Comment = $comment;
	}
    }
?>
