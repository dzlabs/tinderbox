<?php
#-
# Copyright (c) 2004-2007 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/webui/core/Port.php,v 1.5 2007/06/09 22:09:12 marcus Exp $
#

    require_once 'TinderObject.php';

    class Port extends TinderObject {

	function Port($argv = array()) {
	    $object_hash = array(
                'build_id' => '',
		'port_id' => '',
		'port_name' => '',
		'port_directory' => '',
		'port_comment' => '',
		'port_maintainer' => '',
		'currently_building' => '',
		'last_built' => '',
		'last_status' => '',
		'last_successful_built' => '',
		'last_built_version' => '',
		'last_failed_dependency' => '',
		'last_run_duration' => '',
		'last_fail_reason' => ''
	    );

	    $this->TinderObject($object_hash, $argv);
	}

        function getBuildId() {
            return $this->build_id;
        }

	function getId() {
	    return $this->port_id;
	}

	function getName() {
	    return $this->port_name;
	}

	function getDirectory() {
	    return $this->port_directory;
	}

	function getComment() {
	    return $this->port_comment;
	}

	function getMaintainer() {
	    return $this->port_maintainer;
	}

	function getCurrentlyBuilding() {
	    return $this->_truth_array[$this->currently_building];
	}

	function getLastBuilt() {
	    return $this->last_built;
	}

	function getLastStatus() {
	    return $this->last_status;
	}

	function getLastSuccessfulBuilt() {
	    return $this->last_successful_built;
	}

	function getLastBuiltVersion() {
	    return $this->last_built_version;
	}

	function getLastFailReason() {
	    return $this->last_fail_reason;
	}

	function getLastFailedDep() {
	    return $this->last_failed_dependency;
	}

	function getLastRunDuration() {
	    return $this->last_run_duration;
	}

	function getLogfileName() {
	    return $this->getLastBuiltVersion() . ".log";
	}

	function setName($name) {
	    $this->port_name = $name;
	}

	function setDirectory($dir) {
	    $this->port_directory = $dir;
	}

	function setComment($comment) {
	    $this->port_comment = $comment;
	}

	function setMaintainer($maintainer) {
	    $this->port_maintainer = $maintainer;
	}


    }
?>
