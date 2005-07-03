<?php
#-
# Copyright (c) 2005 Oliver Lehmann <oliver@FreeBSD.org>
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
# $MCom: portstools/tinderbox/www-exp/module/moduleBuildPorts.php,v 1.1 2005/07/01 18:09:37 oliver Exp $
#

require_once 'module/module.php';
require_once 'module/modulePorts.php';

class moduleBuildPorts extends module {

	function moduleBuildPorts() {
		$this->module();
		$this->modulePorts = new modulePorts();
	}
	
	function display_list_buildports( $build_name ) {

		$build = $this->TinderboxDS->getBuildByName( $build_name );
		$ports = $this->TinderboxDS->getPortsForBuild( $build );
		$ports_tree = $this->TinderboxDS->getPortsTreeById( $build->getPortsTreeId() );
		$jail = $this->TinderboxDS->getJailById( $build->getJailId() );
		
		if( is_array( $ports ) && count( $ports ) > 0 ) {
			$this->template_assign( 'data', $this->modulePorts->get_list_data( $build_name, $ports ) );
		} else {
			$this->template_assign( 'no_list', 1 );
		}

		$this->template_assign( 'maintainers',            $this->TinderboxDS->getAllMaintainers() );
		$this->template_assign( 'build_description',      $build->getDescription() );
		$this->template_assign( 'build_name',             $build_name );
		$this->template_assign( 'jail_name',              $jail->getName() );
		$this->template_assign( 'jail_tag',               $jail->getTag() );
		$this->template_assign( 'jail_lastbuilt',         $this->TinderboxDS->prettyDatetime( $jail->getLastBuilt() ) );
		$this->template_assign( 'ports_tree_description', $ports_tree->getDescription() );
		$this->template_assign( 'ports_tree_lastbuilt',   $this->TinderboxDS->prettyDatetime( $ports_tree->getLastBuilt() ) );
		$this->template_assign( 'local_time',             $this->TinderboxDS->prettyDatetime( date( 'Y-m-d H:i:s' ) ) );

		return $this->template_parse( 'list_buildports.tpl' );
	}

	function display_failed_buildports( $build_name, $maintainer ) {

		if( $build_name ) {
			$build = $this->TinderboxDS->getBuildByName( $build_name );
			$build_id = $build->getId();
		}

		$ports = $this->TinderboxDS->getPortsByStatus( $build_id, $maintainer, 'FAIL' );
			
		if( is_array( $ports ) && count( $ports ) > 0 ) {
			$this->template_assign( 'data', $this->modulePorts->get_list_data( $build_name, $ports ) );
		} else {
			$this->template_assign( 'no_list', 1 );
		}

		$this->template_assign( 'build_name', $build_name );
		$this->template_assign( 'maintainer', $maintainer );
		$this->template_assign( 'local_time', $this->TinderboxDS->prettyDatetime( date( 'Y-m-d H:i:s' ) ) );

		return $this->template_parse( 'failed_buildports.tpl' );
	}

	function display_latest_buildports( $build_name ) {

		$current_builds = $this->display_current_buildports( $build_name );

		if( $build_name ) {
			$build = $this->TinderboxDS->getBuildByName( $build_name );
			$build_id = $build->getId();
		}

		$ports = $this->TinderboxDS->getLatestPorts( $build_id, 20 );
			
		if( is_array( $ports ) && count( $ports ) > 0 ) {
			$this->template_assign( 'data', $this->modulePorts->get_list_data( $build_name, $ports ) );
		} else {
			$this->template_assign( 'no_list', 1 );
		}

		$this->template_assign( 'current_builds',         $current_builds );
		$this->template_assign( 'build_name',             $build_name );
		$this->template_assign( 'local_time',             $this->TinderboxDS->prettyDatetime( date( 'Y-m-d H:i:s' ) ) );

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
	                foreach( $activeBuilds as $build ) {
				if( $build->getBuildCurrentPort() )
					$data[$i]['port_current_version'] = $build->getBuildCurrentPort();
				else
					$data[$i]['port_current_version'] = $GLOBALS['preparing_next_build'];
					
				$data[$i]['build_name'] = $build->getName();
				$i++;
	                }
			$this->template_assign( 'data', $data );
		} else {
			$this->template_assign( 'no_list', 1 );
	        }

		$this->template_assign( 'build_name', $showbuild );

		return $this->template_parse( 'current_buildports.tpl' );
	}
}	
?>