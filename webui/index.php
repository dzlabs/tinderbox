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
# $MCom: portstools/tinderbox/webui/index.php,v 1.26 2008/09/10 21:29:30 beat Exp $
#

$starttimer = explode( ' ', microtime() );

require_once 'module/moduleBuilds.php';
require_once 'module/moduleBuildPorts.php';
require_once 'module/moduleConfig.php';
require_once 'module/modulePorts.php';
require_once 'module/modulePortFailureReasons.php';
require_once 'module/moduleSession.php';
require_once 'module/moduleTinderd.php';
require_once 'module/moduleUsers.php';
require_once 'module/moduleRss.php';

require_once $templatesdir.'/messages.inc';

$moduleBuilds			= new moduleBuilds();
$moduleBuildPorts		= new moduleBuildPorts();
$moduleConfig			= new moduleConfig();
$modulePorts			= new modulePorts();
$modulePortFailureReasons	= new modulePortFailureReasons();
$moduleSession			= new moduleSession();
$moduleTinderd			= new moduleTinderd();
$moduleUsers			= new moduleUsers();
$moduleRss			= new moduleRss();

$moduleSession->start();
if( isset($_POST['do_login']) ) {
	$moduleUsers->do_login( $_POST['User_Name'], $_POST['User_Password'] );
} elseif( isset($_POST['do_logout']) || ( $moduleUsers->is_logged_in() && !$moduleUsers->get_www_enabled() ) ) {
	$moduleUsers->do_logout();
	header( 'Location: index.php' );
}

$display_login = $moduleUsers->display_login();

$action = $_REQUEST['action'];

switch( $action ) {
	case 'describe_port':		$port_id    = $_REQUEST['id'];
					$display    = $modulePorts->display_describe_port( $port_id );
					break;
	case 'failed_buildports':	$build      = $_REQUEST['build'];
					$maintainer = $_REQUEST['maintainer'];
					$display    = $moduleBuildPorts->display_failed_buildports( $build, $maintainer, null, null );
					break;
	case 'buildports_by_reason':	$build      = $_REQUEST['build'];
					$maintainer = $_REQUEST['maintainer'];
					$reason = $_REQUEST['reason'];
					$display    = $moduleBuildPorts->display_failed_buildports( $build, $maintainer, null, $reason );
					break;
	case 'bad_buildports':		$build      = $_REQUEST['build'];
					$maintainer = $_REQUEST['maintainer'];
					$display    = $moduleBuildPorts->display_failed_buildports( $build, $maintainer, 'foo', null );
					break;
	case 'latest_buildports':	$build      = $_REQUEST['build'];
					$display    = $moduleBuildPorts->display_latest_buildports( $build );
					break;
	case 'list_buildports':		$build      = $_REQUEST['build'];
					$sort       = '';
					if (isset($_REQUEST['sort'])) {
						$sort = $_REQUEST['sort'];
					}
					$display    = $moduleBuildPorts->display_list_buildports( $build, $sort );
					break;
	case 'list_tinderd_queue':	$build_id   = $_REQUEST['filter_build_id'];
					$display    = $moduleTinderd->list_tinderd_queue( $build_id );
					break;
	case 'change_tinderd_queue':	$ctinderdq  = $_REQUEST['change_tinderd_queue'];
					$entry_id   = $_REQUEST['entry_id'];
					$build_id   = $_REQUEST['build_id'];
					$priority   = $_REQUEST['priority'];
					$emailoc    = $_REQUEST['email_on_completion'];
					$moduleTinderd->change_tinderd_queue( $ctinderdq, $entry_id, $build_id, $priority, $emailoc );
					$build_id   = $_REQUEST['filter_build_id'];
					$display    = $moduleTinderd->list_tinderd_queue( $build_id );
					break;
	case 'add_tinderd_queue':	$atinderdq  = $_REQUEST['add_tinderd_queue'];
					$build_id   = $_REQUEST['new_build_id'];
					$priority   = $_REQUEST['new_priority'];
					$directory  = $_REQUEST['new_port_directory'];
					$emailoc    = $_REQUEST['new_email_on_completion'];
					$moduleTinderd->add_tinderd_queue( $atinderdq, $build_id, $priority, $directory, $emailoc );
					$build_id   = $_REQUEST['filter_build_id'];
					$display    = $moduleTinderd->list_tinderd_queue( $build_id );
					break;
	case 'delete_tinderd_queue':	$dtinderdq  = $_REQUEST['delete_tinderd_queue'];
					$build_id   = $_REQUEST['filter_build_id'];
					$moduleTinderd->delete_tinderd_queue( $dtinderdq, $build_id );
					$display    = $moduleTinderd->list_tinderd_queue( $build_id );
					break;
	case 'display_add_user':	$display    = $moduleUsers->display_add_user( '', '', '', '', array() );
					break;
	case 'add_user':		$user_name  = $_REQUEST['user_name'];
					$user_email = $_REQUEST['user_email'];
					$user_pwd   = $_REQUEST['user_password'];
					$wwwenabled = $_REQUEST['www_enabled'];
					$display    = $moduleUsers->action_user( 'add', '', $user_name, $user_email, $user_pwd, $wwwenabled );
					switch( $display ) {
						case '1':	unset( $display ); header( 'Location: index.php' ); break;
						case '0':	$display = $moduleUsers->display_add_user( $user_name, $user_email, $user_pwd, $wwwenabled ); break;
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
					$display    = $moduleUsers->action_user( $actionuser, $user_id, $user_name, $user_email, $user_pwd, $wwwenabled );
					switch( $display ) {
						case '1':	unset( $display ); header( 'Location: index.php' ); break;
						case '0':	$display = $moduleUsers->display_modify_user( 0, $user_id, $user_name, $user_email, $user_pwd, $www_enabled ); break;
					}
					break;
	case 'display_failure_reasons':	$failure_reason_tag  = $_REQUEST['failure_reason_tag'];
					$display    = $modulePortFailureReasons->display_failure_reasons( $failure_reason_tag );
					break;
	case 'config':			$display    = $moduleConfig->display_config();
					break;
	case 'latest_buildports_rss':
					$display    = $moduleRss->display_latest_buildports();
					break;
	case 'list_builds':
	default:			$display    = $moduleBuilds->display_list_builds();
					break;
}

echo $display;

?>
