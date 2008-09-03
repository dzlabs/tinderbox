<?php
#-
# Copyright (c) 2007 Aron Schlesinger <as@paefchen.net>
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
#

require_once 'module/module.php';
require_once 'module/modulePorts.php';

class moduleRss extends module {

	function moduleRss() {
		$this->module();
		$this->modulePorts = new modulePorts();
	}

	function display_latest_buildports( $limit = 20 ) {
		global $wwwrooturi;

		$ports = array();

		foreach ( $this->TinderboxDS->getLatestPorts( false, $limit ) as $port ) {
			$build = $this->TinderboxDS->getBuildById( $port->getBuildId() );
			$jail = $this->TinderboxDS->getJailById( $build->getJailId() );

			list( $data ) = $this->modulePorts->get_list_data( '', array($port) );
			$data['port_last_status'] = $port->getLastStatus();
			$data['jail_name'] = $jail->getName();

			$ports[] = $data;
		}

		$this->template_assign( 'data', $ports );
		$this->template_assign( 'wwwrooturi', $wwwrooturi );
		$this->template_assign( 'lastBuildDate', date('r') );

		return $this->template_parse( 'rss.tpl' );
	}
}

?>
