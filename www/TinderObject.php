<?php

    class TinderObject {
	var $_object_hash = array();

	function TinderObject($object_hash, $attrs = array()) {
	    $this->_object_hash = $object_hash;

	    foreach ($attrs as $key => $value) {
		if (isset($this->_object_hash[$key])) {
		    $this->$key = $value;
		}
	    }
	}

	function toHashRef() {
	    $hashref = array();

	    foreach ($this->_object_hash as $key => $value) {
		$hashref[$key] = $value;
	    }

	    return $hashref;
	}
    }
?>
