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
# $MCom: portstools/tinderbox/webui/module/moduleConfig.php,v 1.1 2005/11/15 19:42:56 oliver Exp $
#

require_once 'module/module.php';
require_once 'module/moduleUsers.php';

class moduleConfig extends module {

	function moduleConfig() {
		$this->module();
		$this->moduleUsers = new moduleUsers();
	}

	function _array_sort_and_assign( $sort_me, $tpl_key ) {
		if( is_array( $sort_me ) && count( $sort_me ) > 0 ) {
			foreach( $sort_me as $res )
				$sort[] = $res[$tpl_key.'_name'];
			array_multisort( $sort, SORT_ASC, $sort_me );
		        $this->template_assign( $tpl_key.'_data',    $sort_me );
			$this->template_assign( 'no_'.$tpl_key.'_list', false );
		} else {
			$this->template_assign( 'no_'.$tpl_key.'_list', true );
		}
	}

	function display_config() {
	       if( !$this->moduleUsers->is_logged_in() ) {
		       return $this->template_parse( 'please_login.tpl' );
	       } else if( ! $this->moduleUsers->checkWwwAdmin() ) {
		       $this->TinderboxDS->addError( permission_denied );
		       return $this->template_parse( 'config.tpl' );
	       }
		$builds          = $this->TinderboxDS->getAllBuilds();
		$jails           = $this->TinderboxDS->getAllJails();
		$ports_trees     = $this->TinderboxDS->getAllPortsTrees();
		$hosts           = $this->TinderboxDS->getAllHosts();
		$config_options  = $this->TinderboxDS->getAllConfig();

		foreach( $hosts as $host ) {
			$host_id = $host->getId();
			$all_hosts[$host_id] = array( 'host_name' => $host->getName() );
		};

		foreach( $jails as $jail ) {
			$jail_id = $jail->getId();
			$all_jails[$jail_id] = array( 'jail_name'        => $jail->getName(),
			                              'jail_tag'         => $jail->getTag(),
			                              'jail_last_built'  => $this->TinderboxDS->prettyDatetime($jail->getLastBuilt()),
			                              'jail_update_cmd'  => $jail->getUpdateCmd(),
			                              'jail_description' => $jail->getDescription(),
			                              'jail_src_mount'   => $jail->getSrcMount() );
		};

		foreach( $ports_trees as $ports_tree ) {
			$ports_tree_id = $ports_tree->getId();
			$all_ports_trees[$ports_tree_id] = array( 'ports_tree_name'        => $ports_tree->getName(),
			                   	        	  'ports_tree_last_built'  => $this->TinderboxDS->prettyDatetime( $ports_tree->getLastBuilt() ),
			                   	        	  'ports_tree_update_cmd'  => $ports_tree->getUpdateCmd(),
			                   	        	  'ports_tree_description' => $ports_tree->getDescription(),
		                           	        	  'ports_tree_cvsweb_url'  => $ports_tree->getCVSwebURL(),
			                   	        	  'ports_tree_ports_mount' => $ports_tree->getPortsMount() );
		};

		foreach( $builds as $build ) {
			$build_id = $build->getId();
			$all_builds[$build_id] = array( 'build_name'        => $build->getName(),
			                   	        'build_description' => $build->getDescription(),
		                           	        'jail_name'         => $all_jails[$build->getJailId()]['jail_name'],
			                   	        'ports_tree_name'   => $all_ports_trees[$build->getPortsTreeId()]['ports_tree_name'] );
		};

		foreach( $config_options as $config_option ) {
			$all_config_options[] = array( 'config_option_name'  => $config_option->getName(),
			                               'config_option_value' => $config_option->getValue(),
			                               'host_name'           => $all_hosts[$config_option->getHostId()]['host_name'] );
		};

		$this->_array_sort_and_assign( $all_hosts,          'host'          );
		$this->_array_sort_and_assign( $all_jails,          'jail'          );
		$this->_array_sort_and_assign( $all_ports_trees,    'ports_tree'    );
		$this->_array_sort_and_assign( $all_builds,         'build'         );
		$this->_array_sort_and_assign( $all_config_options, 'config_option' );

		return $this->template_parse( 'config.tpl' );
	}

}
?>
