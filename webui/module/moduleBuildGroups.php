<?php
#-
# Copyright (c) 2005 Oliver Lehmann <oliver@FreeBSD.org>
# Copyright (c) 2010 Beat Gätzi <beat@FreeBSD.org>
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
# $MCom: portstools/tinderbox/webui/module/moduleBuildGroups.php,v 1.1 2010/11/07 11:34:46 beat Exp $
#

require_once 'module/module.php';
require_once 'module/moduleBuilds.php';
require_once 'module/moduleUsers.php';

class moduleBuildGroups extends module {

	function moduleBuildGroups( $TinderboxDS, $moduleUsers ) {
		$this->module( $TinderboxDS );
		$this->moduleUsers = $moduleUsers;
	}

	function add_build_group( $build_group_name, $build_id ) {
		global $moduleSession;

		if( !$this->moduleUsers->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		} else {
			if( empty( $build_id ) || empty( $build_group_name ) ) {
				$this->TinderboxDS->addError( mandatory_input_fields_are_empty );
				return false;
			} else {
				$build_group_entry = $this->TinderboxDS->addBuildGroupEntry( $build_group_name, $build_id );
				if ( ! $build_group_entry ) {
					$this->TinderboxDS->addError( "Could not create build group entry." );
					return false;
				}
			}
		}
		return;
	}

	function add_build_group_queue( $build_group_name, $priority, $directory, $emailoc ) {

		$buildgroups = $this->get_list_data();

		$i = 0;
		foreach( $buildgroups as $buildgroup ) {
			if ( $build_group_name == $buildgroup['build_group_name'] ) {
				$queue_entry[$i]['build_id'] = $buildgroup['build_id'];
				$queue_entry[$i]['priority'] = $priority;
				$queue_entry[$i]['directory'] = $directory;
				$queue_entry[$i]['emailoc'] = $emailoc;
				$i++;
			}
		}
		return $queue_entry;
	}


	function display_build_groups() {

		global $with_timer, $starttimer, $with_meminfo;

		$meminit = memory_get_usage();

		$buildgroups = $this->TinderboxDS->getAllBuildGroups();

		$data = $this->get_list_data();

		if( is_array( $buildgroups ) && count( $buildgroups ) > 0 ) {
			$this->template_assign( 'data', $data );
			$this->template_assign( 'no_list', false );
		} else {
			$this->template_assign( 'no_list', true );
		}

		$builds = $this->TinderboxDS->getAllBuilds();

		$i = 0;
		foreach( $builds as $build ) {
			$buildlist[$i]['build_id'] = $build->getId();
			$buildlist[$i]['build_name'] = $build->getName();
			$i++;
		}

		$this->template_assign( 'builds' , $buildlist );
		$this->template_assign( 'is_logged_in' , $this->moduleUsers->is_logged_in() );

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

		return $this->template_parse( 'display_build_groups.tpl' );
	}

	function get_list_data() {

		$buildgroups = $this->TinderboxDS->getAllBuildGroups();

		if( is_array( $buildgroups ) && count( $buildgroups ) > 0 ) {
			$i = 0;
			foreach( $buildgroups as $buildgroup ) {
				$data[$i]['build_group_name'] = $buildgroup->getBuildGroupName();
				$data[$i]['build_id'] = $buildgroup->getBuildId();
				$build = $this->TinderboxDS->getBuildById( $buildgroup->getBuildId() );
				$data[$i]['build_name'] = $build->getName();
				$i++;
			}
			return $data;
		} else {
			return NULL;
		}
	}
}
?>
