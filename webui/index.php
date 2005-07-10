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
# $MCom: portstools/tinderbox/webui/index.php,v 1.2 2005/07/10 07:39:17 oliver Exp $
#

$starttimer = explode( ' ', microtime() );

require_once 'module/moduleBuilds.php';
require_once 'module/moduleBuildPorts.php';
require_once 'module/modulePorts.php';
require_once 'module/moduleSession.php';
require_once 'module/moduleTinderd.php';
require_once 'module/moduleUsers.php';

require_once $templatesdir.'/messages.inc';

$moduleBuilds		= new moduleBuilds();
$moduleBuildPorts	= new moduleBuildPorts();
$modulePorts		= new modulePorts();
$moduleSession		= new moduleSession();
$moduleTinderd		= new moduleTinderd();
$moduleUsers		= new moduleUsers();

$moduleSession->start();
if( $_POST['do_login'] ) {
	$moduleUsers->do_login($_POST['User_Name'],$_POST['User_Password']);
} elseif( $_POST['do_logout'] || ( $moduleUsers->is_logged_in() && !$moduleUsers->get_www_enabled() ) ) {
	$moduleUsers->do_logout();
	header("Location: index.php");
}

$display_login = $moduleUsers->display_login();

$action = $_POST['action']?$_POST['action']:$_GET['action'];

if( $action ) {
	$moduleSession->setAttribute( 'action', $action);
} else {
	$action = $moduleSession->getAttribute( 'action' );
}

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
	case 'list_tinderd_queue':	$host_id    = $_POST['filter_host_id']?$_POST['filter_host_id']:$_GET['filter_host_id'];
					$build_id   = $_POST['filter_build_id']?$_POST['filter_build_id']:$_GET['filter_build_id'];
					$display    = $moduleTinderd->list_tinderd_queue( $host_id, $build_id );
					break;
	case 'change_tinderd_queue':	$change_tinderd_queue = $_POST['change_tinderd_queue']?$_POST['change_tinderd_queue']:$_GET['change_tinderd_queue'];
					$entry_id   = $_POST['entry_id']?$_POST['entry_id']:$_GET['entry_id'];
					$host_id    = $_POST['host_id']?$_POST['host_id']:$_GET['host_id'];
					$build_id   = $_POST['build_id']?$_POST['build_id']:$_GET['build_id'];
					$priority   = $_POST['priority']?$_POST['priority']:$_GET['priority'];
					$moduleTinderd->change_tinderd_queue( $change_tinderd_queue, $entry_id, $host_id, $build_id, $priority );
					$host_id    = $_POST['filter_host_id']?$_POST['filter_host_id']:$_GET['filter_host_id'];
					$build_id   = $_POST['filter_build_id']?$_POST['filter_build_id']:$_GET['filter_build_id'];
					$display    = $moduleTinderd->list_tinderd_queue( $host_id, $build_id );
					break;	
	case 'add_tinderd_queue':	$add_tinderd_queue = $_POST['add_tinderd_queue']?$_POST['add_tinderd_queue']:$_GET['add_tinderd_queue'];
					$host_id    = $_POST['new_host_id']?$_POST['new_host_id']:$_GET['new_host_id'];
					$build_id   = $_POST['new_build_id']?$_POST['new_build_id']:$_GET['new_build_id'];
					$priority   = $_POST['new_priority']?$_POST['new_priority']:$_GET['new_priority'];
					$port_directory = $_POST['new_port_directory']?$_POST['new_port_directory']:$_GET['new_port_directory'];
					$moduleTinderd->add_tinderd_queue( $add_tinderd_queue, $host_id, $build_id, $priority, $port_directory );
					$host_id    = $_POST['filter_host_id']?$_POST['filter_host_id']:$_GET['filter_host_id'];
					$build_id   = $_POST['filter_build_id']?$_POST['filter_build_id']:$_GET['filter_build_id'];
					$display    = $moduleTinderd->list_tinderd_queue( $host_id, $build_id );
					break;	
	case 'display_add_user':	$display    = $moduleUsers->display_add_user( '', '', '', '', array() );
					break;
	case 'add_user':		$user_name  = $_POST['user_name']?$_POST['user_name']:$_GET['user_name'];
					$user_email = $_POST['user_email']?$_POST['user_email']:$_GET['user_email'];
					$user_password = $_POST['user_password']?$_POST['user_password']:$_GET['user_password'];
					$www_enabled = $_POST['www_enabled']?$_POST['www_enabled']:$_GET['www_enabled'];
					$permission_object = $_POST['permission_object']?$_POST['permission_object']:$_GET['permission_object'];
					$display    = $moduleUsers->action_user( "add", $user_name, $user_email, $user_password, $www_enabled, $permission_object );
					switch( $display ) {
						case "1":	header("Location: index.php"); break;
						case "0":	$display = $moduleUsers->display_add_user( $user_name, $user_email, $user_password, $www_enabled, $permission_object ); break;
					}
					break;
	case 'display_modify_user':	$user_name  = $_POST['modify_user_name']?$_POST['modify_user_name']:$_GET['modify_user_name'];
					$display    = $moduleUsers->display_modify_user( 1, $user_name, '', '', '', '', array() );
					break;
	case 'modify_user':		$action_user = $_POST['action_user']?$_POST['action_user']:$_GET['action_user'];
					$user_name   = $_POST['user_name']?$_POST['user_name']:$_GET['user_name'];
					$user_email  = $_POST['user_email']?$_POST['user_email']:$_GET['user_email'];
					$user_password = $_POST['user_password']?$_POST['user_password']:$_GET['user_password'];
					$www_enabled = $_POST['www_enabled']?$_POST['www_enabled']:$_GET['www_enabled'];
					$permission_object = $_POST['permission_object']?$_POST['permission_object']:$_GET['permission_object'];
					$display     = $moduleUsers->action_user( $action_user, $user_name, $user_email, $user_password, $www_enabled, $permission_object );
					switch( $display ) {
						case "1":	header("Location: index.php"); break;
						case "0":	$display = $moduleUsers->display_modify_user( 0, $user_name, $user_email, $user_password, $www_enabled, $permission_object ); break;
					}
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
