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
# $MCom: portstools/tinderbox/webui/core/Jail.php,v 1.5 2005/12/17 23:36:14 ade Exp $
#

    require_once 'TinderObject.php';

    class Jail extends TinderObject {

	function Jail($argv = array()) {
	    $object_hash = array(
		'jail_id' => '',
		'jail_name' => '',
		'jail_arch' => '',
		'jail_tag' => '',
		'jail_last_built' => '',
		'jail_update_cmd' => '',
		'jail_description' => '',
		'jail_src_mount' => ''
	    );

	    $this->TinderObject($object_hash, $argv);
	}

	function getId() {
	    return $this->jail_id;
	}

	function getName() {
	    return $this->jail_name;
	}

	function getArch() {
	    return $this->jail_arch;
	}

	function getTag() {
	    return $this->jail_tag;
	}

	function getLastBuilt() {
	    return $this->jail_last_built;
	}

	function getUpdateCmd() {
	    return $this->jail_update_cmd;
	}

	function getDescription() {
	    return $this->jail_description;
	}

	function getSrcMount() {
	    return $this->jail_src_mount;
	}

	function setName($name) {
	    $this->jail_name = $name;
	}

	function setArch($tag) {
	    $this->jail_arch = $tag;
	}

	function setTag($tag) {
	    $this->jail_tag = $tag;
	}

	function setLastBuilt($time) {
	    $this->jail_last_built = $time;
	}

	function setUpdateCmd($cmd) {
	    $this->jail_update_cmd = $cmd;
	}

	function setDescription($descr) {
	    $this->jail_description = $descr;
	}
    }
?>
