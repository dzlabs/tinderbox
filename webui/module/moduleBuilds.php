<?php
#-
# Copyright (c) 2005 Oliver Lehmann <oliver@FreeBSD.org>
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
# $MCom: portstools/tinderbox/webui/module/moduleBuilds.php,v 1.2 2005/07/10 07:39:18 oliver Exp $
#

require_once 'module/module.php';

class moduleBuilds extends module {

	function moduleBuilds() {
		$this->module();
	}
	
	function display_list_builds() {
		global $pkgdir;
		global $pkguri;

		$builds = $this->TinderboxDS->getAllBuilds();
		
		if( is_array( $builds ) && count( $builds ) > 0 ) {
			$data = $this->get_list_data( $builds );
			foreach( $data as $res )
				$sort[] = $res['name'];
			array_multisort( $sort, SORT_ASC, $data );
			$this->template_assign( 'data', $data );
		} else {
			$this->template_assign( 'no_list', 1 );
		}

		$this->template_assign( 'maintainers', $this->TinderboxDS->getAllMaintainers() );
		return $this->template_parse( 'list_builds.tpl' );
	}

	function get_list_data( $builds ) {
		global $pkgdir;
		global $pkguri;

		$i = 0;
		foreach( $builds as $build ) {
			$stats       = $this->TinderboxDS->getBuildStats( $build->getId() );
			$status      = $build->getBuildStatus();
			$description = $build->getDescription();
			$name        = $build->getName();

			$failures    = $stats['fails'];
			
			switch( $status ) {
				case 'PORTBUILD':
					$status_field_class = 'build_portbuild';
					break;
				case 'PREPARE':
					$status_field_class = 'build_prepare';
					break;
				default:
					$status_field_class = 'build_default';
					break;
			}

			$data[$i]['status_field_class'] = $status_field_class;
			$data[$i]['name'] = $name;
			$data[$i]['description'] = $description;
			if( is_dir( $pkgdir.'/'.$name ) )
				$data[$i]['packagedir'] = $pkguri.'/'.$name ;
			if( $failures > 0 )
				$data[$i]['failures'] = $failures;
			$i++;
		}

		return $data;

	}

	function get_all_builds() {
		$all_builds_raw = $this->TinderboxDS->getAllBuilds();
		$all_builds = array();
		foreach( $all_builds_raw as $build ) {
			$all_builds[] = array( 'build_id' => $build->getId(), 'build_name' => $build->getName() );
		}
		return $all_builds;
	}
}	
?>
