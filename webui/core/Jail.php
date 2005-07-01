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
# $MCom: portstools/tinderbox/webui/core/Jail.php,v 1.1 2005/07/01 18:20:51 oliver Exp $
#

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
