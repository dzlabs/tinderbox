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
# $MCom: portstools/tinderbox/webui/core/PortsTree.php,v 1.3 2005/07/21 11:28:29 oliver Exp $
#

    require_once 'TinderObject.php';

    class PortsTree extends TinderObject {

	function PortsTree($argv = array()) {
	    $object_hash = array(
		'Ports_Tree_Id' => '',
		'Ports_Tree_Name' => '',
		'Ports_Tree_Description' => '',
		'Ports_Tree_Last_Built' => '',
		'Ports_Tree_Update_Cmd' => '',
                'Ports_Tree_CVSweb_URL' => ''
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

        function getCVSwebURL() {
            return $this->Ports_Tree_CVSweb_URL;
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
