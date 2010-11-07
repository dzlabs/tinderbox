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
# $MCom: portstools/tinderbox/webui/index.php,v 1.40 2010/11/07 11:19:53 beat Exp $
#

$starttimer = explode( ' ', microtime() );

require_once 'core/TinderboxDS.php';
require_once 'module/moduleBuilds.php';
require_once 'module/moduleSession.php';
require_once 'module/moduleUsers.php';

require_once $templatesdir.'/messages.inc';

$req_moduleBuilds		= false;
$req_modulePorts		= false;
$req_moduleBuildGroups		= false;
$req_moduleBuildPorts		= false;
$req_moduleLogs			= false;
$req_modulePortFailureReasons	= false;
$req_moduleUsers		= false;
$req_moduleConfig		= false;
$req_moduleTinderd		= false;
$req_moduleRss			= false;

$action = isset( $_REQUEST['action'] ) ? $_REQUEST['action'] : '';

switch( $action ) {
	case 'describe_port':
					$req_modulePorts		= true;
					break;
	case 'failed_buildports':
	case 'buildports_by_reason':
	case 'bad_buildports':
	case 'latest_buildports':
	case 'list_buildports':
					$req_modulePorts		= true;
					$req_moduleBuildPorts		= true;
					break;
	case 'list_tinderd_queue':
	case 'change_tinderd_queue':
	case 'add_tinderd_queue':
	case 'delete_tinderd_queue':
	case 'add_build_group_queue':
					$req_moduleBuildGroups		= true;
					$req_moduleTinderd		= true;
					break;
	case 'display_add_user':
	case 'add_user':
	case 'display_modify_user':
	case 'modify_user':
					break;
	case 'display_failure_reasons':
					$req_modulePortFailureReasons	= true;
					break;
	case 'config':
					$req_moduleConfig		= true;
					break;
	case 'latest_buildports_rss':
					$req_modulePorts		= true;
					$req_moduleRss			= true;
					break;
	case 'display_markup_log':
					$req_modulePorts		= true;
					$req_moduleLogs			= true;
	case 'add_build_group':
	case 'list_build_group':
					$req_moduleBuildGroups		= true;
					break;
	case 'list_builds':
					break;
}


$TinderboxDS			= new TinderboxDS();
$moduleSession			= new moduleSession( $TinderboxDS );
$moduleBuilds			= new moduleBuilds( $TinderboxDS );
$moduleUsers			= new moduleUsers( $TinderboxDS, $moduleBuilds );

if( $req_modulePorts === true ) {
	require_once 'module/modulePorts.php';
	$modulePorts			= new modulePorts( $TinderboxDS );
}
if( $req_moduleBuildPorts === true ) {
	require_once 'module/moduleBuildPorts.php';
	$moduleBuildPorts		= new moduleBuildPorts( $TinderboxDS, $modulePorts );
}
if( $req_moduleLogs === true ) {
	require_once 'module/moduleLogs.php';
	$moduleLogs			= new moduleLogs( $TinderboxDS, $modulePorts );
}
if( $req_modulePortFailureReasons  === true ) {
	require_once 'module/modulePortFailureReasons.php';
	$modulePortFailureReasons	= new modulePortFailureReasons( $TinderboxDS );
}
if( $req_moduleConfig === true ) {
	require_once 'module/moduleConfig.php';
	$moduleConfig			= new moduleConfig( $TinderboxDS, $moduleUsers );
}
if( $req_moduleBuildGroups === true ) {
	require_once 'module/moduleBuildGroups.php';
	$moduleBuildGroups		= new moduleBuildGroups ( $TinderboxDS, $moduleUsers );
}
if( $req_moduleTinderd === true ) {
	require_once 'module/moduleTinderd.php';
	$moduleTinderd			= new moduleTinderd( $TinderboxDS, $moduleBuilds, $moduleBuildGroups, $moduleUsers );
}
if( $req_moduleRss  === true ) {
	require_once 'module/moduleRss.php';
	$moduleRss			= new moduleRss( $TinderboxDS, $modulePorts );
}

$moduleSession->start();
if ( isset( $_POST['do_login'] ) ) {
	$moduleUsers->do_login( $_POST['User_Name'], $_POST['User_Password'] );
} elseif ( isset( $_POST['do_logout'] ) || ( $moduleUsers->is_logged_in() && !$moduleUsers->get_www_enabled() ) ) {
	$moduleUsers->do_logout();
	header( 'Location: index.php' );
}

$display_login = $moduleUsers->display_login();


switch( $action ) {
	case 'describe_port':		$port_id    = $_REQUEST['id'];
					$display    = $modulePorts->display_describe_port( $port_id );
					break;
	case 'failed_buildports':	$build      = isset ( $_REQUEST['build'] ) ? $_REQUEST['build'] : '';
					$maintainer = isset ( $_REQUEST['maintainer'] ) ? $_REQUEST['maintainer'] : '';
					$sort       = isset ( $_REQUEST['sort'] ) ? $_REQUEST['sort'] : '';
					$list_limit_offset = isset ( $_REQUEST['list_limit_offset'] ) ? $_REQUEST['list_limit_offset'] : '0';
					$display    = $moduleBuildPorts->display_failed_buildports( $build, $maintainer, null, null, $list_limit_offset, $sort );
					break;
	case 'buildports_by_reason':	$build      = $_REQUEST['build'];
					$maintainer = isset ( $_REQUEST['maintainer'] ) ? $_REQUEST['maintainer'] : '';
					$reason = $_REQUEST['reason'];
					$sort       = isset ( $_REQUEST['sort'] ) ? $_REQUEST['sort'] : '';
					$list_limit_offset = isset ( $_REQUEST['list_limit_offset'] ) ? $_REQUEST['list_limit_offset'] : '0';
					$display    = $moduleBuildPorts->display_failed_buildports( $build, $maintainer, null, $reason, $list_limit_offset, $sort );
					break;
	case 'bad_buildports':		$build      = isset ( $_REQUEST['build'] ) ? $_REQUEST['build'] : '';
					$maintainer = isset ( $_REQUEST['maintainer'] ) ? $_REQUEST['maintainer'] : '';
					$sort       = isset ( $_REQUEST['sort'] ) ? $_REQUEST['sort'] : '';
					$list_limit_offset = isset ( $_REQUEST['list_limit_offset'] ) ? $_REQUEST['list_limit_offset'] : '0';
					$display    = $moduleBuildPorts->display_failed_buildports( $build, $maintainer, 'foo', null, $list_limit_offset, $sort );
					break;
	case 'latest_buildports':	$build      = isset ( $_REQUEST['build'] ) ? $_REQUEST['build'] : '';
					$display    = $moduleBuildPorts->display_latest_buildports( $build );
					break;
	case 'list_buildports':		$build      = $_REQUEST['build'];
					$sort       = isset ( $_REQUEST['sort'] ) ? $_REQUEST['sort'] : '';
					$search     = isset ( $_REQUEST['search_port_name'] ) ? $_REQUEST['search_port_name'] : '';
					$list_limit_offset = isset ( $_REQUEST['list_limit_offset'] ) ? $_REQUEST['list_limit_offset'] : '0';
					$display    = $moduleBuildPorts->display_list_buildports( $build, $sort, $search, $list_limit_offset );
					break;
	case 'list_tinderd_queue':	$build_id   = isset ( $_REQUEST['filter_build_id'] ) ? $_REQUEST['filter_build_id'] : '';
					$display    = $moduleTinderd->list_tinderd_queue( $build_id );
					break;
	case 'change_tinderd_queue':	$ctinderdq  = $_REQUEST['change_tinderd_queue'];
					$entry_id   = $_REQUEST['entry_id'];
					$build_id   = $_REQUEST['build_id'];
					$priority   = $_REQUEST['priority'];
					$emailoc    = isset ( $_REQUEST['new_email_on_completion'] ) ? $_REQUEST['new_email_on_completion'] : '';
					$moduleTinderd->change_tinderd_queue( $ctinderdq, $entry_id, $build_id, $priority, $emailoc );
					$build_id   = $_REQUEST['filter_build_id'];
					$display    = $moduleTinderd->list_tinderd_queue( $build_id );
					break;
	case 'add_tinderd_queue':	$atinderdq  = $_REQUEST['add_tinderd_queue'];
					$build_id   = $_REQUEST['new_build_id'];
					$priority   = $_REQUEST['new_priority'];
					$directory  = $_REQUEST['new_port_directory'];
					$emailoc    = isset ( $_REQUEST['new_email_on_completion'] ) ? $_REQUEST['new_email_on_completion'] : '';
					$moduleTinderd->add_tinderd_queue( $atinderdq, $build_id, $priority, $directory, $emailoc );
					$build_id   = $_REQUEST['filter_build_id'];
					$display    = $moduleTinderd->list_tinderd_queue( $build_id );
					break;
	case 'delete_tinderd_queue':	$dtinderdq  = $_REQUEST['delete_tinderd_queue'];
					$build_id   = isset ( $_REQUEST['filter_build_id'] ) ? $_REQUEST['filter_build_id'] : '';
					$moduleTinderd->delete_tinderd_queue( $dtinderdq, $build_id );
					$display    = $moduleTinderd->list_tinderd_queue( $build_id );
					break;
	case 'display_add_user':	$display    = $moduleUsers->display_add_user( '', '', '', '', array() );
					break;
	case 'add_user':		$user_name  = $_REQUEST['user_name'];
					$user_email = $_REQUEST['user_email'];
					$user_pwd   = $_REQUEST['user_password'];
					$wwwenabled = $_REQUEST['www_enabled'];
					$perm_obj   = $_REQUEST['permission_object'];
					$display    = $moduleUsers->action_user( 'add', '', $user_name, $user_email, $user_pwd, $wwwenabled, $perm_obj );
					switch( $display ) {
						case '1':	unset( $display ); header( 'Location: index.php' ); break;
						case '0':	$display = $moduleUsers->display_add_user( $user_name, $user_email, $user_pwd, $wwwenabled, $perm_obj ); break;
					}
					break;
	case 'display_modify_user':	$user_id  = $_REQUEST['modify_user_id'];
					$display    = $moduleUsers->display_modify_user( 1, $user_id, '', '', '', '', array() );
					break;
	case 'modify_user':		$actionuser = $_REQUEST['action_user'];
					$user_id    = $_REQUEST['user_id'];
					$user_name  = $_REQUEST['user_name'];
					$user_email = $_REQUEST['user_email'];
					$user_pwd   = $_REQUEST['user_password'];
					$wwwenabled = $_REQUEST['www_enabled'];
					$perm_obj   = $_REQUEST['permission_object'];
					$display    = $moduleUsers->action_user( $actionuser, $user_id, $user_name, $user_email, $user_pwd, $wwwenabled, $perm_obj );
					switch( $display ) {
						case '1':	unset( $display ); header( 'Location: index.php' ); break;
						case '0':	$display = $moduleUsers->display_modify_user( 0, $user_id, $user_name, $user_email, $user_pwd, $www_enabled, $perm_obj ); break;
					}
					break;
	case 'display_failure_reasons':	$failure_reason_tag  = $_REQUEST['failure_reason_tag'];
					$display    = $modulePortFailureReasons->display_failure_reasons( $failure_reason_tag );
					break;
	case 'config':			$display    = $moduleConfig->display_config();
					break;
	case 'latest_buildports_rss':
					$maintainer = isset ( $_REQUEST['maintainer'] ) ? $_REQUEST['maintainer'] : '';
					$display    = $moduleRss->display_latest_buildports( $maintainer );
					break;
	case 'display_markup_log':	$build = $_REQUEST['build'];
					$id        = $_REQUEST['id'];
					$display	= $moduleLogs->markup_log( $build, $id );
					break;
	case 'add_build_group':		$build_group_name = $_REQUEST['build_group_name'];
					$build_id   = $_REQUEST['build_id'];
					$moduleBuildGroups->add_build_group( $build_group_name, $build_id );
					$display    = $moduleBuildGroups->display_build_groups();
					break;
	case 'add_build_group_queue':	$build_group_name = $_REQUEST['build_group_name'];
					$priority   = $_REQUEST['new_priority'];
					$directory  = $_REQUEST['new_port_directory'];
					$emailoc    = isset ( $_REQUEST['new_email_on_completion'] ) ? $_REQUEST['new_email_on_completion'] : '';
					$tinderd_queue = $moduleBuildGroups->add_build_group_queue( $build_group_name, $priority, $directory, $emailoc );
					foreach ( $tinderd_queue as $entry ) {
						$moduleTinderd->add_tinderd_queue( 'add', $entry['build_id'], $entry['priority'], $entry['directory'], $entry['emailoc'] );
					}
					$display    = $moduleTinderd->list_tinderd_queue( NULL );
					break;
	case 'list_build_group':	$display    = $moduleBuildGroups->display_build_groups();
					break;
	case 'list_builds':
	default:			$display    = $moduleBuilds->display_list_builds();
					break;
}

echo $display;

?>
