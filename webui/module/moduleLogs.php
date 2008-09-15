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
# $MCom: portstools/tinderbox/webui/module/moduleLogs.php,v 1.1 2008/09/15 16:33:14 beat Exp $
#

require_once 'module/module.php';
require_once 'module/modulePorts.php';

class moduleLogs extends module {

	function moduleLogs() {
		$this->module();
		$this->modulePorts = new modulePorts();
	}

	function markup_log( $build_id, $id, $pattern_ids, $show_line_number, $show_error, $show_warning, $show_information ) {
		global $rootdir, $logdir;
		global $with_timer, $starttimer;

		$ports = $this->TinderboxDS->getAllPortsByPortID( $id );
		$build = $this->TinderboxDS->getBuildByName( $build_id );

		foreach ( $ports as $port ) {
			if ( $port->getBuildID() == $build->getID() ) {
				$build_port = $port;
				break;
			}
		}

		$data  = $this->modulePorts->get_list_data( $build_id, $ports );

		if ( $build_port->getLastStatus() == 'FAIL' ) {
			foreach ( $this->TinderboxDS->getAllPortFailPatterns() as $pattern ) {
				if ( $pattern->getExpr() != '.*' ) {
					$patterns[$pattern->getId()]['id']       = $pattern->getId();
					$patterns[$pattern->getId()]['tag']      = $pattern->getReason();
					$patterns[$pattern->getId()]['severity'] = 'error';
					$patterns[$pattern->getId()]['expr']     = '/' . addcslashes( $pattern->getExpr(), '/' ) . '/';
					$patterns[$pattern->getId()]['color']    = 'red';
					$patterns[$pattern->getId()]['counter']  = 0;
					if ( !empty ( $pattern_ids ) ) {
						foreach ( $pattern_ids as $pattern_id ) {
							if ( $pattern_id == $pattern->getId() ) {
								$patterns[$pattern->getId()]['show'] = 'yes';
								break;
							}
						}
					}
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
				if ( !empty ( $pattern_ids ) ) {
					foreach ( $pattern_ids as $pattern_id ) {
						if ( $pattern_id == $pattern->getId() ) {
							$patterns[$pattern->getId()]['show'] = 'yes';
							break;
						}
					}
				}
			}
		}

		if ( $show_error == 'yes' ) {
			array_walk( $patterns, create_function( '&$pattern', 'if ( $pattern["severity"] == "error") { $pattern["show"] = "yes"; }' ) );
		}

		if ( $show_warning == 'yes' ) {
			array_walk( $patterns, create_function( '&$pattern', 'if ( $pattern["severity"] == "warning") { $pattern["show"] = "yes"; }' ) );
		}

		if ( $show_information == 'yes' ) {
			array_walk( $patterns, create_function( '&$pattern', 'if ( $pattern["severity"] == "information") { $pattern["show"] = "yes"; }' ) );
		}

		foreach ( $data as $port_data ) {
			if ( !empty ( $port_data['port_link_logfile'] ) ) {
				$file_name = $port_data['port_logfile_path'];
				break;
			}
		}

		if ( !( is_file( $file_name ) ) ) {
			die( 'File cannot be opened for reading.' );
		}

		$file_name  = realpath( $file_name );

		if ( strpos( $file_name, $logdir ) !== 0 ) {
			die( 'So long, and thanks for all the fish' );
		}

		$lines = file( $file_name );

		$counter['error']       = 0;
		$counter['warning']     = 0;
		$counter['information'] = 0;

		for( $i = 0; $i < sizeof( $lines ); $i++ ) {

			$j = 0;

			$lines[$i] = chop( $lines[$i] );
			$lines[$i] = htmlentities( $lines[$i] );

			foreach ( $patterns as $pattern ) {
				if ( empty( $lines[$i] ) ) {
					$lines[$i] = '&nbsp;';	
				}
				else {
					if ( preg_match( $pattern['expr'] , $lines[$i] ) ) {
						$result[$i]['severity'] = $pattern['severity'];
						$result[$i]['line']     = $lines[$i];
						if ( $pattern['show'] == 'yes' ) {
							$result[$i]['color']    = $pattern['color'];
						}
						$patterns[$pattern['id']]['counter']++;
						$counter[$pattern['severity']]++;
						$j = 1;
						break;
					}
				}
			}
			if ( $j == 0 ) {
				$result[$i]['color'] = 'None';
				$result[$i]['line']  = $lines[$i];
			}
		}

		$this->template_assign( 'counter', $counter );
		$this->template_assign( 'show_line_number', $show_line_number );
		$this->template_assign( 'result', $result );
		$this->template_assign( 'build', $build_id );
		$this->template_assign( 'id', $id );
		$this->template_assign( 'patterns', $patterns );
		$elapsed_time = '';
		if ( isset( $with_timer ) && $with_timer == 1) {
			$elapsed_time = get_ui_elapsed_time( $starttimer );
		}
		$this->template_assign( 'ui_elapsed_time', $elapsed_time );
		return $this->template_parse( 'display_markup_log.tpl' );
	}
}
?>
