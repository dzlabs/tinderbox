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
# $MCom: portstools/tinderbox/webui/index.php,v 1.6 2005/07/11 05:52:31 oliver Exp $
#

$starttimer = explode( ' ', microtime() );

function get_var( $var ) {
	return $_POST[$var]?$_POST[$var]:$_GET[$var];
}

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
	$moduleUsers->do_login( $_POST['User_Name'], $_POST['User_Password'] );
} elseif( $_POST['do_logout'] || ( $moduleUsers->is_logged_in() && !$moduleUsers->get_www_enabled() ) ) {
	$moduleUsers->do_logout();
	header( 'Location: index.php' );
}

$display_login = $moduleUsers->display_login();

$action = get_var( 'action' );

if( $action ) {
	$moduleSession->setAttribute( 'action', $action );
} else {
	$action = $moduleSession->getAttribute( 'action' );
}

switch( $action ) {
	case 'describe_port':		$port_id    = get_var( 'id' );
					$display    = $modulePorts->display_describe_port( $port_id );
					break;
	case 'failed_buildports':	$build      = get_var( 'build' );
					$maintainer = get_var( 'maintainer' );
					$display    = $moduleBuildPorts->display_failed_buildports( $build, $maintainer );
					break;
	case 'latest_buildports':	$build      = get_var( 'build' );
					$display    = $moduleBuildPorts->display_latest_buildports( $build );
					break;
	case 'list_buildports':		$build      = get_var( 'build' );
					$display    = $moduleBuildPorts->display_list_buildports( $build );
					break;
	case 'list_tinderd_queue':	$host_id    = get_var( 'filter_host_id' );
					$build_id   = get_var( 'filter_build_id' );
					$display    = $moduleTinderd->list_tinderd_queue( $host_id, $build_id );
					break;
	case 'change_tinderd_queue':	$ctinderdq  = get_var( 'change_tinderd_queue' );
					$entry_id   = get_var( 'entry_id' );
					$host_id    = get_var( 'host_id' );
					$build_id   = get_var( 'build_id' );
					$priority   = get_var( 'priority' );
					$moduleTinderd->change_tinderd_queue( $ctinderdq, $entry_id, $host_id, $build_id, $priority );
					$host_id    = get_var( 'filter_host_id' );
					$build_id   = get_var( 'filter_build_id' );
					$display    = $moduleTinderd->list_tinderd_queue( $host_id, $build_id );
					break;
	case 'add_tinderd_queue':	$atinderdq  = get_var( 'add_tinderd_queue' );
					$host_id    = get_var( 'new_host_id' );
					$build_id   = get_var( 'new_build_id' );
					$priority   = get_var( 'new_priority' );
					$directory  = get_var( 'new_port_directory' );
					$moduleTinderd->add_tinderd_queue( $atinderdq, $host_id, $build_id, $priority, $directory );
					$host_id    = get_var( 'filter_host_id' );
					$build_id   = get_var( 'filter_build_id' );
					$display    = $moduleTinderd->list_tinderd_queue( $host_id, $build_id );
					break;
	case 'display_add_user':	$display    = $moduleUsers->display_add_user( '', '', '', '', array() );
					break;
	case 'add_user':		$user_name  = get_var( 'user_name' );
					$user_email = get_var( 'user_email' );
					$user_pwd   = get_var( 'user_password' );
					$wwwenabled = get_var( 'www_enabled' );
					$perm_obj   = get_var( 'permission_object' );
					$display    = $moduleUsers->action_user( 'add', '', $user_name, $user_email, $user_pwd, $wwwenabled, $perm_obj );
					switch( $display ) {
						case '1':	unset( $display ); header( 'Location: index.php' ); break;
						case '0':	$display = $moduleUsers->display_add_user( $user_name, $user_email, $user_pwd, $wwwenabled, $perm_obj ); break;
					}
					break;
	case 'display_modify_user':	$user_id  = get_var( 'modify_user_id' );
					$display    = $moduleUsers->display_modify_user( 1, $user_id, '', '', '', '', array() );
					break;
	case 'modify_user':		$actionuser = get_var( 'action_user' );
					$user_id    = get_var( 'user_id' );
					$user_name  = get_var( 'user_name' );
					$user_email = get_var( 'user_email' );
					$user_pwd   = get_var( 'user_password' );
					$wwwenabled = get_var( 'www_enabled' );
					$perm_obj   = get_var( 'permission_object' );
					$display    = $moduleUsers->action_user( $actionuser, $user_id, $user_name, $user_email, $user_pwd, $wwwenabled, $perm_obj );
					switch( $display ) {
						case '1':	unset( $display ); header( 'Location: index.php' ); break;
						case '0':	$display = $moduleUsers->display_modify_user( 0, $user_id, $user_name, $user_email, $user_pwd, $www_enabled, $perm_obj ); break;
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
