<?php
#-
# Copyright (c) 2004-2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
# Copyright (c) 2008 Beat Gätzi <beat@chruetertee.ch>
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
# $MCom: portstools/tinderbox/webui/core/PortFailPattern.php,v 1.1 2008/09/15 16:33:13 beat Exp $
#

require_once 'TinderObject.php';

class PortFailPattern extends TinderObject {

	function PortFailPattern( $argv = array() ) {
		$object_hash = array(
			'port_fail_pattern_id' => '',
			'port_fail_pattern_expr' => '',
			'port_fail_pattern_reason' => '',
			'port_fail_pattern_parent' => ''
		);

		$this->TinderObject( $object_hash, $argv );
	}

	function getId() {
		return $this->port_fail_pattern_id;
	}

	function getExpr() {
		return $this->port_fail_pattern_expr;
	}

	function getReason() {
		return $this->port_fail_pattern_reason;
	}

	function getParent() {
		return $this->port_fail_pattern_parent;
	}
}
?>
