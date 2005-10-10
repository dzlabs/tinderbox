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
# $MCom: portstools/tinderbox/webui/core/User.php,v 1.4 2005/10/10 23:30:16 ade Exp $
#

    require_once 'TinderObject.php';

    class User extends TinderObject {

	function User($argv = array()) {
	    $object_hash = array(
                'user_id' => '',
		'user_name' => '',
		'user_email' => '',
		'user_password' => '',
		'user_www_enabled' => ''
	    );

	    $this->TinderObject($object_hash, $argv);
	}

	function getId() {
	    return $this->user_id;
	}

	function getName() {
	    return $this->user_name;
	}

	function getEmail() {
	    return $this->user_email;
	}

	function getPassword() {
	    return $this->user_password;
	}

	function getWwwEnabled() {
	    return $this->_truth_array[$this->user_www_enabled];
	}

	function setName($name) {
	    return $this->user_name = $name;
	}

	function setEmail($email) {
	    return $this->user_email = $email;
	}

	function setPassword($password) {
	    return $this->user_password = $password;
	}

	function setWwwEnabled($www_enabled) {
	    return $this->user_www_enabled = $www_enabled;
	}
    }
?>
