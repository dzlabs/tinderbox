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
# $MCom: portstools/tinderbox/www-exp/core/User.php,v 1.1 2005/07/10 07:39:18 oliver Exp $
#

    require_once 'TinderObject.php';

    class User extends TinderObject {

	function User($argv = array()) {
	    $object_hash = array(
                User_Id => "",
		User_Name => "",
		User_Email => "",
		User_Password => "",
		User_Www_Enabled => ""
	    );

	    $this->TinderObject($object_hash, $argv);
	}

	function getId() {
	    return $this->User_Id;
	}

	function getName() {
	    return $this->User_Name;
	}

	function getEmail() {
	    return $this->User_Email;
	}

	function getPassword() {
	    return $this->User_Password;
	}

	function getWwwEnabled() {
	    return $this->User_Www_Enabled;
	}

	function setName($name) {
	    return $this->User_Name = $name;
	}

	function setEmail($email) {
	    return $this->User_Email = $email;
	}

	function setPassword($password) {
	    return $this->User_Password = $password;
	}

	function setWwwEnabled($www_enabled) {
	    return $this->User_Www_Enabled = $www_enabled;
	}
    }
?>
