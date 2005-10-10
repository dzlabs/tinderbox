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
# $MCom: portstools/tinderbox/www/PortsTree.php,v 1.5 2005/10/10 23:30:15 ade Exp $
#

    require_once 'TinderObject.php';

    class PortsTree extends TinderObject {

	function PortsTree($argv = array()) {
	    $object_hash = array(
		ports_tree_id => "",
		ports_tree_name => "",
		ports_tree_description => "",
		ports_tree_last_built => "",
		ports_tree_update_cmd => ""
	    );

	    $this->TinderObject($object_hash, $argv);
	}

	function getId() {
	    return $this->ports_tree_id;
	}

	function getName() {
	    return $this->ports_tree_name;
	}

	function getDescription() {
	    return $this->ports_tree_description;
	}

	function getLastBuilt() {
	    return $this->ports_tree_last_built;
	}

	function getUpdateCmd() {
	    return $this->ports_tree_update_cmd;
	}

	function setName($name) {
	    $this->ports_tree_name = $name;
	}

	function setDescription($descr) {
	    $this->ports_tree_description = $descr;
	}

	function setLastBuilt($time) {
	    $this->ports_tree_last_built = $time;
	}

	function setUpdateCmd($cmd) {
	    $this->ports_tree_update_cmd = $cmd;
	}
    }
?>
