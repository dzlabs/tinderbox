<?php
#-
# Copyright (c) 2005 Oliver Lehmann <oliver@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#	notice, this list of conditions and the following disclaimer
# 2. Redistributions in binary form must reproduce the above copyright
#	notice, this list of conditions and the following disclaimer in the
#	documentation and/or other materials provided with the distribution.
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
# $MCom: portstools/tinderbox/webui/module/moduleSession.php,v 1.4 2009/01/02 14:16:28 beat Exp $
#

require_once 'module/module.php';

class moduleSession extends module {

	function moduleSession( $TinderboxDS ) {
		$this->module( $TinderboxDS );
	}

	function setAttribute( $attribute, $value ) {
		if( !session_id() ) {
			if( !$this->start() ) {
				return false;
			}
		}

		$_SESSION[$attribute] = $value;
		return true;
	}

	function getAttribute( $attribute ) {
		if( isset( $_SESSION[$attribute] ) ) {
			return $_SESSION[$attribute];
		} else {
			return false;
		}
	}

	function removeAttribute( $attribute ) {
		unset( $_SESSION[$attribute] );
	}

	function start() {
		if( !headers_sent() ) {
			session_start();
			return true;
		}
		return false;
	}

	function destroy() {
		if( session_id() ) {
			session_destroy();
		}
	}
}
?>
