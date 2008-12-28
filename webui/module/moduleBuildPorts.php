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
# $MCom: portstools/tinderbox/webui/module/moduleBuildPorts.php,v 1.22 2008/12/28 23:47:29 beat Exp $
#

require_once 'module/module.php';
require_once 'module/modulePorts.php';

class moduleBuildPorts extends module {

	function moduleBuildPorts() {
		$this->module();
		$this->modulePorts = new modulePorts();
	}

	function display_list_buildports( $build_name, $sort, $search_port_name ) {
		global $starttimer, $with_timer;

		$build = $this->TinderboxDS->getBuildByName( $build_name );
		$ports = $this->TinderboxDS->getPortsForBuild( $build, $sort, $search_port_name );
		$ports_tree = $this->TinderboxDS->getPortsTreeById( $build->getPortsTreeId() );
		$jail = $this->TinderboxDS->getJailById( $build->getJailId() );

		if( is_array( $ports ) && count( $ports ) > 0 ) {
			$this->template_assign( 'data', $this->modulePorts->get_list_data( $build_name, $ports ) );
			$this->template_assign( 'no_list', false );
		} else {
			$this->template_assign( 'no_list', true );
		}

		foreach( $this->TinderboxDS->getAllPortFailReasons() as $reason ) {
			$port_fail_reasons[$reason->getTag()]['tag']   = htmlentities( $reason->getTag() );
			$port_fail_reasons[$reason->getTag()]['descr'] = $reason->getDescr();
			$port_fail_reasons[$reason->getTag()]['type']  = $reason->getType();
			$port_fail_reasons[$reason->getTag()]['link']  = true;
		}

		foreach ( $ports as $port ) {
			if ( $port->getLastFailedDep() != '' ) {
				$depreason = $port->getLastFailedDep();
				$port_fail_reasons[$depreason]['tag']   = htmlentities( $depreason );
				$port_fail_reasons[$depreason]['descr'] = htmlentities( "Port was not built since dependency $depreason failed." );
				$port_fail_reasons[$depreason]['type']  = 'COMMON';
				$port_fail_reasons[$depreason]['link']  = false;

			}
		}

		$qs = array();
		$qkvs = explode( '&', $_SERVER['QUERY_STRING'] );
		foreach ( $qkvs as $qkv ) {
			$kv = explode( '=', $qkv );
			$qs[$kv[0]] = $kv[1];
		}

		$this->template_assign( 'port_fail_reasons',      $port_fail_reasons );
		$this->template_assign( 'maintainers',            $this->TinderboxDS->getAllMaintainers() );
		$this->template_assign( 'build_description',      $build->getDescription() );
		$this->template_assign( 'build_name',             $build_name );
		$this->template_assign( 'jail_name',              $jail->getName() );
		$this->template_assign( 'jail_tag',               $jail->getTag() );
		$this->template_assign( 'jail_lastbuilt',         prettyDatetime( $jail->getLastBuilt() ) );
		$this->template_assign( 'ports_tree_description', $ports_tree->getDescription() );
		$this->template_assign( 'ports_tree_lastbuilt',   prettyDatetime( $ports_tree->getLastBuilt() ) );
		$this->template_assign( 'local_time',             prettyDatetime( date( 'Y-m-d H:i:s' ) ) );
		$this->template_assign( 'search_port_name',       htmlentities( $search_port_name ) );
		$elapsed_time = '';
		if ( isset( $with_timer ) && $with_timer == 1 ) {
			$elapsed_time = get_ui_elapsed_time( $starttimer );
		}
		$this->template_assign( 'ui_elapsed_time',        $elapsed_time );
		$this->template_assign( 'querystring',            $qs );

		return $this->template_parse( 'list_buildports.tpl' );
	}

	function display_failed_buildports( $build_name, $maintainer, $all, $wanted_reason  ) {
		global $with_timer, $starttimer;

		if( $build_name ) {
			$build = $this->TinderboxDS->getBuildByName( $build_name );
			$build_id = $build->getId();
		} else {
			$build_id = false;
		}

		if ( $wanted_reason ) {
			$ports = $this->TinderboxDS->getPortsByStatus( $build_id, NULL, $wanted_reason, '' );
		}
		else {
			if ( $all ) {
				$ports = $this->TinderboxDS->getPortsByStatus( $build_id, $maintainer, '', 'SUCCESS' );
			} else {
				$ports = $this->TinderboxDS->getPortsByStatus( $build_id, $maintainer, 'FAIL', '' );
			}
		}

		if( is_array( $ports ) && count( $ports ) > 0 ) {
			$this->template_assign( 'data', $this->modulePorts->get_list_data( $build_name, $ports ) );
			$this->template_assign( 'no_list', false );
		} else {
			$this->template_assign( 'no_list', true );
		}

		foreach( $this->TinderboxDS->getAllPortFailReasons() as $reason ) {
			$port_fail_reasons[$reason->getTag()]['tag']   = htmlentities( $reason->getTag() );
			$port_fail_reasons[$reason->getTag()]['descr'] = $reason->getDescr();
			$port_fail_reasons[$reason->getTag()]['type']  = $reason->getType();
			$port_fail_reasons[$reason->getTag()]['link']  = true;
		}

		foreach ( $ports as $port ) {
			if ( $port->getLastFailedDep() != "" ) {
				$depreason = $port->getLastFailedDep();
				$port_fail_reasons[$depreason]['tag']   = htmlentities( $depreason );
				$port_fail_reasons[$depreason]['descr'] = htmlentities( "Port was not built since dependency $depreason failed." );
				$port_fail_reasons[$depreason]['type']  = 'COMMON';
				$port_fail_reasons[$depreason]['link']  = false;
			}
		}

		$this->template_assign( 'port_fail_reasons',      $port_fail_reasons );
		$this->template_assign( 'build_name', $build_name );
		$this->template_assign( 'maintainer', $maintainer );
		$this->template_assign( 'local_time', prettyDatetime( date( 'Y-m-d H:i:s' ) ) );
		$elapsed_time = '';
		if ( isset( $with_timer ) && $with_timer == 1 ) {
			$elapsed_time = get_ui_elapsed_time( $starttimer );
		}
		$this->template_assign( 'ui_elapsed_time',           $elapsed_time );
		$this->template_assign( 'reason',                    $wanted_reason );

		return $this->template_parse( 'failed_buildports.tpl' );
	}

	function display_latest_buildports( $build_name ) {
		global $with_timer, $starttimer;

		$current_builds = $this->display_current_buildports( $build_name );

		if( $build_name ) {
			$build = $this->TinderboxDS->getBuildByName( $build_name );
			$build_id = $build->getId();
		} else {
			$build_id = false;
		}

		$ports = $this->TinderboxDS->getLatestPorts( $build_id, 30 );

		if( is_array( $ports ) && count( $ports ) > 0 ) {
			$this->template_assign( 'data', $this->modulePorts->get_list_data( $build_name, $ports ) );
			$this->template_assign( 'no_list', false );
		} else {
			$this->template_assign( 'no_list', true );
		}

		foreach( $this->TinderboxDS->getAllPortFailReasons() as $reason ) {
			$port_fail_reasons[$reason->getTag()]['tag']   = htmlentities( $reason->getTag() );
			$port_fail_reasons[$reason->getTag()]['descr'] = $reason->getDescr();
			$port_fail_reasons[$reason->getTag()]['type']  = $reason->getType();
			$port_fail_reasons[$reason->getTag()]['link']  = true;
		}

		foreach ( $ports as $port ) {
			if ( $port->getLastFailedDep() != "" ) {
				$depreason = $port->getLastFailedDep();
				$port_fail_reasons[$depreason]['tag']   = htmlentities( $depreason );
				$port_fail_reasons[$depreason]['descr'] = htmlentities( "Port was not built since dependency $depreason failed." );
				$port_fail_reasons[$depreason]['type']  = 'COMMON';
				$port_fail_reasons[$depreason]['link']  = false;
			}
		}

		$this->template_assign( 'port_fail_reasons',      $port_fail_reasons );
		$this->template_assign( 'current_builds',         $current_builds );
		$this->template_assign( 'build_name',             $build_name );
		$this->template_assign( 'local_time',             prettyDatetime( date( 'Y-m-d H:i:s' ) ) );
		$elapsed_time = '';
		if ( isset( $with_timer ) && $with_timer == 1 ) {
			$elapsed_time = get_ui_elapsed_time( $starttimer );
		}
		$this->template_assign( 'ui_elapsed_time',           $elapsed_time );

		return $this->template_parse( 'latest_buildports.tpl' );
	}

	function display_current_buildports( $showbuild ) {
		$activeBuilds = array();
		$builds = $this->TinderboxDS->getBuilds();
		if( $builds ) {
			foreach( $builds as $build ) {
				if( empty( $showbuild ) || $build->getName() == $showbuild ) {
					if( $build->getBuildStatus() == 'PORTBUILD' ) {
						$activeBuilds[] = $build;
					}
				}
			}
		}

		if( sizeof( $activeBuilds ) > 0 ) {
			$i = 0;
			foreach( $activeBuilds as $build ) {
				if( $build->getBuildCurrentPort() )
					$data[$i]['port_current_version'] = $build->getBuildCurrentPort();
				else
					$data[$i]['port_current_version'] = preparing_next_build;

				$data[$i]['build_name'] = $build->getName();
				$data[$i]['build_last_updated'] = $build->getBuildLastUpdated();
				$data[$i]['build_eta'] = 'N/A';
				$currport = $this->TinderboxDS->getCurrentPortForBuild( $build->getId() );
				if ( !is_null( $currport ) ) {
					$bp = $this->TinderboxDS->getBuildPorts( $currport->getId(), $build->getId() );
					$as = explode( ' ', $build->getBuildLastUpdated() );
					$ymd = explode( '-', $as[0] );
					$hms = explode( ':', $as[1] );
					$then = mktime( $hms[0], $hms[1], $hms[2], $ymd[1], $ymd[2], $ymd[0] );
					$diff = time() - $then;
					if ( $bp->getLastRunDuration() - $diff >= 0 )
						$data[$i]['build_eta'] = $bp->getLastRunDuration() - $diff;
				}
				$build_ports_queue_entries = $this->TinderboxDS->getBuildPortsQueueEntries( $build->getId() );
				foreach( $build_ports_queue_entries as $build_ports_queue_entry ) {
					if ( $build_ports_queue_entry->getStatus() == 'PROCESSING' )
						$data[$i]['target_port'] = $build_ports_queue_entry->getPortDirectory();
				}
				if ( empty ( $data[$i]['target_port'] ) ) {
					$data[$i]['target_port'] = 'n/a';
				}
				$i++;
			}
			$this->template_assign( 'data', $data );
			$this->template_assign( 'no_list', false );
		} else {
			$this->template_assign( 'no_list', true );
		}

		$this->template_assign( 'build_name', $showbuild );

		return $this->template_parse( 'current_buildports.tpl' );
	}
}
?>
