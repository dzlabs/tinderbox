<?php
#-
# Copyright (c) 2005-2008 Oliver Lehmann <oliver@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer
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
# $MCom: portstools/tinderbox/webui/module/modulePortFailureReasons.php,v 1.8 2009/01/02 14:16:28 beat Exp $
#

require_once 'module/module.php';

class modulePortFailureReasons extends module {

	function modulePortFailureReasons( $TinderboxDS ) {
		$this->module( $TinderboxDS );
	}

	function display_failure_reasons( $reason_tag ) {
		global $with_timer, $starttimer, $with_meminfo;

		$meminit = memory_get_usage();

		foreach( $this->TinderboxDS->getAllPortFailReasons() as $reason ) {
			$port_fail_reasons[$reason->getTag()]['tag']   = htmlentities( $reason->getTag() );
			$port_fail_reasons[$reason->getTag()]['descr'] = $reason->getDescr();
			$port_fail_reasons[$reason->getTag()]['type']  = $reason->getType();
		}

		$this->template_assign( 'port_fail_reasons',      $port_fail_reasons );
		$this->template_assign( 'mark_reason',            $reason_tag );
		$this->template_assign( 'local_time',             prettyDatetime( date( 'Y-m-d H:i:s' ) ) );
		$elapsed_time = '';
		if ( isset( $with_timer ) && $with_timer == 1 ) {
			$elapsed_time = get_ui_elapsed_time( $starttimer );
		}
		$this->template_assign( 'ui_elapsed_time',           $elapsed_time );
		$mem_info = '';
		if ( isset ( $with_meminfo ) && $with_meminfo == 1 ) {
			$mempeak = memory_get_peak_usage();
			$memend  = memory_get_usage();
			$mem_info = get_mem_consumption ( $meminit, $mempeak, $memend );
		}
		$this->template_assign( 'mem_info',               $mem_info);
		return $this->template_parse( 'list_failure_reasons.tpl' );
	}


}
?>
