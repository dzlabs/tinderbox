<?php
#-
# Copyright (c) 2004-2008 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/webui/core/Build.php,v 1.5 2008/08/04 23:18:10 marcus Exp $
#

    require_once 'TinderObject.php';

    class Build extends TinderObject {

	function Build($argv = array()) {
	    $object_hash = array(
		'build_id' => '',
		'build_name' => '',
		'jail_id' => '',
		'ports_tree_id' => '',
		'build_description' => '',
		'build_status' => '',
		'build_current_port' => '',
		'build_last_updated' => '',
		'build_remake_count' => ''
	    );

	    $this->TinderObject($object_hash, $argv);
	}

	function getId() {
	    return $this->build_id;
	}

	function getName() {
	    return $this->build_name;
	}

	function getJailId() {
	    return $this->jail_id;
	}

	function getPortsTreeId() {
	    return $this->ports_tree_id;
	}

	function getDescription() {
	    return $this->build_description;
	}

	function getBuildStatus() {
	    return $this->build_status;
	}

	function getBuildCurrentPort() {
	    return $this->build_current_port;
	}

	function getBuildLastUpdated() {
	    return $this->build_last_updated;
	}

	function getBuildRemakeCount() {
	    return $this->build_remake_count;
	}

	function setName($name) {
	    $this->build_name = $name;
	}

	function setJailId($id) {
	    $this->jail_id = $id;
	}

	function setPortsTreeId($id) {
	    $this->ports_tree_id = $id;
	}

	function setDescription($descr) {
	    $this->build_description = $descr;
	}

	function setBuildStatus($status) {
	    $this->build_status = $status;
	}

	function setBuildCurrentPort($port) {
	    $this->build_current_port = $port;
	}

	function setBuildRemakeCount($cnt) {
	    $this->build_remake_count = $cnt;
	}

    }
?>
