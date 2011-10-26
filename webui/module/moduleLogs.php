<?php
#-
# Copyright (c) 2008 Beat Gätzi <beat@chruetertee.ch>
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
# $MCom: portstools/tinderbox/webui/module/moduleLogs.php,v 1.10 2011/10/26 08:39:35 beat Exp $
#

require_once 'module/module.php';
require_once 'module/modulePorts.php';

class moduleLogs extends module {

	function moduleLogs( $TinderboxDS, $modulePorts ) {
		$this->module( $TinderboxDS );
		$this->modulePorts = $modulePorts;
	}

	function markup_log( $build_id, $id ) {
		global $rootdir, $logdir;
		global $with_timer, $starttimer, $with_meminfo;

		$meminit = memory_get_usage();

		$ports = $this->TinderboxDS->getAllPortsByPortID( $id );
		if ( ! $ports ) {
			$this->TinderboxDS->addError( "Unknown port id : " . htmlentities( $id ) );
			return $this->template_parse( 'display_markup_log.tpl' );
		}

		$build = $this->TinderboxDS->getBuildByName( $build_id );
		if ( ! $build ) {
			$this->TinderboxDS->addError( "Unknown build id : " . htmlentities( $build_id ) );
			return $this->template_parse( 'display_markup_log.tpl' );
		}

		foreach ( $ports as $port ) {
			if ( $port->getBuildID() == $build->getID() ) {
				$build_port = $port;
				break;
			}
		}

		list( $data ) = $this->modulePorts->get_list_data( $build_id, array( $build_port ) );

		$patterns = array();

		if ( $build_port->getLastStatus() == 'FAIL' ) {
			foreach ( $this->TinderboxDS->getAllPortFailPatterns() as $pattern ) {
				if ( $pattern->getExpr() != '.*' ) {
					$patterns[$pattern->getId()]['id']       = $pattern->getId();
					$patterns[$pattern->getId()]['tag']      = $pattern->getReason();
					$patterns[$pattern->getId()]['severity'] = 'error';
					$patterns[$pattern->getId()]['expr']     = '/' . addcslashes( $pattern->getExpr(), '/' ) . '/';
					$patterns[$pattern->getId()]['color']    = 'red';
					$patterns[$pattern->getId()]['counter']  = 0;
				}
			}
		} else {
			foreach( $this->TinderboxDS->getAllLogfilePatterns() as $pattern ) {
				$patterns[$pattern->getId()]['id']       = $pattern->getId();
				$patterns[$pattern->getId()]['tag']      = $pattern->getTag();
				$patterns[$pattern->getId()]['severity'] = $pattern->getSeverity();
				$patterns[$pattern->getId()]['expr']     = $pattern->getExpr();
				$patterns[$pattern->getId()]['color']    = $pattern->getColor();
				$patterns[$pattern->getId()]['counter']  = 0;
			}
		}

		if ( !( is_file( $data['port_logfile_path'] ) ) ) {
			$this->TinderboxDS->addError( "File cannot be opened for reading: " . $data['port_logfile_path'] );
			return $this->template_parse( 'display_markup_log.tpl' );
		}

		$file_name = realpath( $data['port_logfile_path'] );

		if ( strpos( $file_name, $logdir ) !== 0 ) {
			$this->TinderboxDS->addError( "File " . $file_name . " not in log directory: " . $logdir );
			return $this->template_parse( 'display_markup_log.tpl' );
		}

		$lines = array();
		$stats = array();
		$colors = array();
		$counts = array();
		$displaystats = array();
		$is_compressed = false;
		$fh = NULL;

		if ( preg_match( "/\.bz2$/", $file_name ) ) {
			$fh = bzopen( $file_name, 'r' );
			$is_compressed = true;
		} else {
			$fh = fopen( $file_name, 'r' );
		}

		for ( $lnr = 1; ! feof( $fh ); $lnr++ ) {
			if ( ! $is_compressed ) {
				$line = fgets( $fh );
			} else {
				$line = '';
				while( ! feof( $fh ) ) {
					$b = bzread( $fh, 1 );
					if ( $b === FALSE ) break;
					$line .= $b;
					if ( $b == "\n" ) break;
				}
			}

			$lines[$lnr] = htmlentities( rtrim( $line ) );
			$colors[$lnr] = '';

			foreach ( $patterns as $pattern ) {
				if ( !preg_match( $pattern['expr'], $line ) )
					continue;

				$colors[$lnr] = $pattern['color'];

				if ( !isset( $stats[$pattern['severity']] ) ) {
					$stats[$pattern['severity']] = array();
					$counts[$pattern['severity']] = 0;
					$displaystats[$pattern['severity']] = true;
					if ( isset( $_COOKIE[$pattern['severity']] ) && $_COOKIE[$pattern['severity']] == '0' )
						$displaystats[$pattern['severity']] = false;
				}

				if ( !isset( $stats[$pattern['severity']][$pattern['tag']] ) )
					$stats[$pattern['severity']][$pattern['tag']] = array();

				$stats[$pattern['severity']][$pattern['tag']][] = $lnr;
				$counts[$pattern['severity']]++;
			}
		}

		if ( ! $is_compressed ) {
			fclose( $fh );
		} else {
			bzclose( $fh );
		}

		$displaystats['linenumber'] = true;
		if ( isset( $_COOKIE['linenumber'] ) && $_COOKIE['linenumber'] == '0' )
			$displaystats['linenumber'] = false;

		$this->template_assign( 'lines', $lines );
		$this->template_assign( 'stats', $stats );
		$this->template_assign( 'colors', $colors );
		$this->template_assign( 'counts', $counts );
		$this->template_assign( 'displaystats', $displaystats );
		$this->template_assign( 'build', $build_id );
		$this->template_assign( 'id', $id );
		$this->template_assign( 'data', $data );

		$elapsed_time = '';
		if ( isset( $with_timer ) && $with_timer == 1 )
			$elapsed_time = get_ui_elapsed_time( $starttimer );

		$this->template_assign( 'ui_elapsed_time', $elapsed_time );

		$mem_info = '';
		if ( isset ( $with_meminfo ) && $with_meminfo == 1 ) {
			$mempeak = memory_get_peak_usage();
			$memend  = memory_get_usage();
			$mem_info = get_mem_consumption ( $meminit, $mempeak, $memend );
		}
		$this->template_assign( 'mem_info', $mem_info);

		return $this->template_parse( 'display_markup_log.tpl' );
	}
}
?>
