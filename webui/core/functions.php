<?php
#-
# Copyright (c) 2004-2008 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/webui/core/functions.php,v 1.11 2011/12/01 18:16:46 beat Exp $
#

function prettyDatetime( $input ) {
	if ( preg_match( '/[0-9]{14}/', $input ) ) {
		/* timstamp */
		return substr( $input, 0, 4) . '-' . substr( $input , 4 , 2 ) . '-' . substr ( $input , 6 , 2 ) . ' ' . substr( $input , 8 , 2 ) . ':' . substr( $input, 10, 2 ) . ':' . substr( $input, 12, 2 );
	} elseif ( preg_match( "/[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/", $input ) ) {
		/* datetime */
		if ( $input == '0000-00-00 00:00:00' ||
			$input == '0000-00-00 00:00:00.000000') {
				return '';
		} else {
			return substr( $input, 0, 19 );
		}
	} else {
		return $input;
	}
}

function cryptPassword( $password ) {
	return md5( $password );
}

function build_query_string( $url, $qs, $key, $value ) {
	$qs[$key] = $value;
	$tmp = array();
	foreach ( $qs as $k => $v ) {
		array_push( $tmp, $k . '=' . $v );
	}
	return $url . '?' . implode( '&amp;', $tmp );
}

function time_difference_from_now( $then ) {
	$then = strtotime( prettyDatetime( $then ) );
	$diff = time() - $then;
	return time_elapsed( $diff );
}

function time_elapsed( $c ) {
	if ( $c === 0 || $c < 0 || $c == '' )
		return '-';
	if ( $c >= 3600 )
		return sprintf( "%0d:%02d:%02d",
			floor( $c/3600 ),floor( ( $c%3600 ) / 60 ), floor( $c%60 ) );
	return sprintf( "%02d:%02d",
		floor( ( $c%3600 ) / 60 ),floor( $c%60 ) );
}

function get_ui_elapsed_time( $starttimer ) {
	$endtimer = explode( ' ', microtime() );
	$timer = ( $endtimer[1]-$starttimer[1] )+( $endtimer[0]-$starttimer[0] );
	return sprintf( 'Elapsed: %03.6f sec.', $timer );
}

function get_mem_consumption ( $meminit, $mempeak, $memend ) {
	$meminit  = $meminit / 1048576;
	$mempeak  = $mempeak / 1048576;
	$memend   = $memend  / 1048576;
	return sprintf( 'Initial: %04.2f MB, Peak: %04.2f MB, End: %04.2f MB', $meminit, $mempeak, $memend );
}

function get_load_average() {
	$load_average = preg_replace(array('/{/','/}/'),'',`/sbin/sysctl -n vm.loadavg`);
	return $load_average;
}

?>
