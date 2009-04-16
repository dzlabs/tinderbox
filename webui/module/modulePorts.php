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
# $MCom: portstools/tinderbox/webui/module/modulePorts.php,v 1.19 2009/04/16 15:41:47 beat Exp $
#

require_once 'module/module.php';

class modulePorts extends module {

	function modulePorts( $TinderboxDS ) {
		$this->module( $TinderboxDS );
	}

	function display_describe_port( $port_id ) {
		global $with_timer, $starttimer, $with_meminfo;

		$meminit = memory_get_usage();

		$ports = $this->TinderboxDS->getAllPortsByPortID( $port_id );
		if ( ! $ports ) {
			$this->TinderboxDS->addError( "Unknown port id : " . htmlentities( $port_id ) );
			$this->template_assign( 'no_list', true );
			return $this->template_parse( 'describe_port.tpl' );
		}

		if( is_array( $ports ) && count( $ports ) > 0 ) {
			$this->template_assign( 'data', $this->get_list_data( '', $ports ) );
			$this->template_assign( 'no_list', false );
		} else {
			$this->template_assign( 'no_list', true );
		}

		foreach( $ports as $port ) {
			$build = $this->TinderboxDS->getBuildById( $port->getBuildId() );
			$ports_tree = $this->TinderboxDS->getPortsTreeForBuild( $build );
			if( empty( $ports_tree_ids[$ports_tree->getId()] ) ) {
				$ports_tree_ids[$ports_tree->getId()] = 1;
				
				$cvsweb_arr = explode( '?', $ports_tree->getCVSwebURL(), 2 );
				if ( count( $cvsweb_arr ) == 1 ) {
					list( $cvsweb ) = $cvsweb_arr;
					$cvsweb_querystr = '';
				} else {
					list( $cvsweb, $cvsweb_querystr ) = $cvsweb_arr;
				}

				if ( $cvsweb_querystr ) {
					$cvsweb = rtrim( $cvsweb, '/' );
					$cvsweb_querystr = '?' . $cvsweb_querystr;
				}

				$ports_trees_links[] = array( 'name' => $ports_tree->getName(), 'cvsweb' => $cvsweb, 'cvsweb_querystr' => $cvsweb_querystr );
			}
		}

		$this->template_assign( 'port_comment',      $ports[0]->getComment() );
		$this->template_assign( 'port_dir',          $ports[0]->getDirectory() );
		$this->template_assign( 'port_maintainer',   $ports[0]->getMaintainer() );
		$this->template_assign( 'port_name',         $ports[0]->getName() );
		$this->template_assign( 'ports_trees_links', $ports_trees_links );
		$this->template_assign( 'local_time',        prettyDatetime( date( 'Y-m-d H:i:s' ) ) );
		$elapsed_time = '';
		if ( isset( $with_timer ) && $with_timer == 1 ) {
			$elapsed_time = get_ui_elapsed_time( $starttimer );
		}
		$this->template_assign( 'ui_elapsed_time',      $elapsed_time );
		$mem_info = '';
		if ( isset ( $with_meminfo ) && $with_meminfo == 1 ) {
			$mempeak = memory_get_peak_usage();
			$memend  = memory_get_usage();
			$mem_info = get_mem_consumption ( $meminit, $mempeak, $memend );
		}
		$this->template_assign( 'mem_info',          $mem_info);

		return $this->template_parse( 'describe_port.tpl' );
	}

	function get_list_data( $build_name, $ports ) {
		global $loguri;
		global $logdir;
		global $errorloguri;
		global $pkguri;

		if( empty( $build_name ) ) {
			$different_builds = true;
		} else {
			$different_builds = false;
			$build = $this->TinderboxDS->getBuildByName( $build_name );
			if ( ! $build ) {
				$this->TinderboxDS->addError( "Unknown build name : " . htmlentities( $build_name ) );
				return false;
			}
			$package_suffix = $this->TinderboxDS->getPackageSuffix( $build->getJailId() );
		}


		foreach( $ports as $port ) {
			if( $different_builds == true ) {
				$build = $this->TinderboxDS->getBuildById( $port->getBuildId() );
				$package_suffix = $this->TinderboxDS->getPackageSuffix( $build->getJailId() );
				$build_name = $build->getName();
			}

			$port_id = $port->getId();
			$port_last_built_version = $port->getLastBuiltVersion();
			$port_logfilename = $port->getLogfileName();
			$port_logfile_path = $logdir . '/' . $build_name . '/' . $port_logfilename;
			$port_link_logfile = $loguri . '/' . $build_name . '/' . $port_logfilename;
			$port_link_package = $pkguri . '/' . $build_name . '/All/' . $port_last_built_version . $package_suffix;
			$port_last_run_duration = $port->getLastRunDuration();
			$port_last_fail_reason = $port->getLastFailReason();

			switch( $port->getLastStatus() ) {
				case 'SUCCESS':
					$status_field_class    = 'port_success';
					$status_field_letter   = '&nbsp;';
					break;
				case 'LEFTOVERS':
					$status_field_class    = 'port_leftovers';
					$status_field_letter   = 'L';
					break;
				case 'BROKEN':
					$status_field_class    = 'port_broken';
					$status_field_letter   = 'B';
					$port_link_package     = '';
					break;
				case 'FAIL':
					$status_field_class    = 'port_fail';
					$status_field_letter   = '&nbsp;';
					$port_link_logfile     = $errorloguri . '/' . $build_name . '/' . $port_logfilename;
					$port_link_package     = '';
					break;
				case 'DEPEND':
					$status_field_class    = 'port_depend';
					$status_field_letter   = '&nbsp;';
					$port_link_logfile     = '';
					$port_link_package     = '';
					$port_last_fail_reason = $port->getLastFailedDep();
					break;
				case 'DUD':
					$status_field_class    = 'port_dud';
					$status_field_letter   = 'D';
					$port_link_logfile     = '';
					$port_link_package     = '';
					break;
				default:
					$status_field_class    = 'port_default';
					$status_field_letter   = '&nbsp;';
					$port_link_logfile     = '';
					$port_link_package     = '';
					break;
			}

			$data[] = array(	'build_name'                 => $build_name,
						'port_directory'             => $port->getDirectory(),
						'port_maintainer'            => $port->getMaintainer().' ',
						'port_id'                    => $port_id,
						'port_logfile_path'          => $port_logfile_path,
						'port_last_built_version'    => $port_last_built_version,
						'port_last_built'            => prettyDatetime( $port->getLastBuilt() ),
						'port_last_successful_built' => prettyDatetime( $port->getLastSuccessfulBuilt() ),
						'port_last_fail_reason'      => htmlentities( $port_last_fail_reason ),
						'port_last_run_duration'     => $port_last_run_duration,
						'port_link_logfile'          => $port_link_logfile,
						'port_link_package'          => $port_link_package,
						'status_field_class'         => $status_field_class,
						'status_field_letter'        => $status_field_letter );
		}
		return $data;
	}
}
?>
