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
# $MCom: portstools/tinderbox/webui/core/Build.php,v 1.2 2005/07/21 11:28:28 oliver Exp $
#

    require_once 'TinderObject.php';

    class Build extends TinderObject {

	function Build($argv = array()) {
	    $object_hash = array(
		'Build_Id' => '',
		'Build_Name' => '',
		'Jail_Id' => '',
		'Ports_Tree_Id' => '',
		'Build_Description' => '',
		'Build_Status' => '',
		'Build_Current_Port' => ''
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

	function getBuildStatus() {
	    return $this->Build_Status;
	}

	function getBuildCurrentPort() {
	    return $this->Build_Current_Port;
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

	function setBuildStatus($status) {
	    $this->Build_Status = $status;
	}

	function setBuildCurrentPort($port) {
	    $this->Build_Current_Port = $port;
	}

    }
?>
