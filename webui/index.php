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
# $MCom: portstools/tinderbox/webui/index.php,v 1.1 2005/07/01 18:09:37 oliver Exp $
#

$starttimer = explode( ' ', microtime() );

require_once 'module/moduleBuilds.php';
require_once 'module/moduleBuildPorts.php';
require_once 'module/modulePorts.php';

require_once $templatesdir.'/messages.inc';

$moduleBuilds		= new moduleBuilds();
$moduleBuildPorts	= new moduleBuildPorts();
$modulePorts		= new modulePorts();

$action = $_POST['action']?$_POST['action']:$_GET['action'];

switch( $action ) {
	case 'describe_port':		$port_id    = $_POST['id']?$_POST['id']:$_GET['id'];
					$display    = $modulePorts->display_describe_port( $port_id );
					break;
	case 'failed_buildports':	$build      = $_POST['build']?$_POST['build']:$_GET['build'];
					$maintainer = $_POST['maintainer']?$_POST['maintainer']:$_GET['maintainer'];
					$display    = $moduleBuildPorts->display_failed_buildports( $build, $maintainer );
					break;
	case 'latest_buildports':	$build      = $_POST['build']?$_POST['build']:$_GET['build'];
					$display    = $moduleBuildPorts->display_latest_buildports( $build );
					break;
	case 'list_buildports':		$build      = $_POST['build']?$_POST['build']:$_GET['build'];
					$display    = $moduleBuildPorts->display_list_buildports( $build );
					break;
	case 'list_builds':
	default:			$display    = $moduleBuilds->display_list_builds();
					break;
}

echo $display;

if( $with_timer == 1 ) {
        $endtimer = explode( ' ', microtime() );
        $timer = ( $endtimer[1]-$starttimer[1] )+( $endtimer[0]-$starttimer[0] );
        printf( '<p style="color:#FF0000;font-size:10px;">elapsed: %03.6f seconds, %s', $timer, ' </p>' );
}
?>
