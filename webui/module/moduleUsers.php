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
# $MCom: portstools/tinderbox/webui/module/moduleUsers.php,v 1.4 2005/07/11 05:52:31 oliver Exp $
#

require_once 'module/module.php';
require_once 'module/moduleBuilds.php';
require_once 'module/moduleHosts.php';

class moduleUsers extends module {

	function moduleUsers() {
		$this->module();
		$this->moduleBuilds = new moduleBuilds();
		$this->moduleHosts  = new moduleHosts();
	}

	function display_login() {
		global $moduleSession;

		if( $this->is_logged_in() ) {
			$this->template_assign( 'user_name', $moduleSession->getAttribute( 'user' )->getName() );
			$this->template_assign( 'user_id',   $moduleSession->getAttribute( 'user' )->getId() );
			if( $this->checkWwwAdmin() ) {
				$this->template_assign( 'is_www_admin', 1 );
				$this->template_assign( 'all_users', $this->get_all_users() );
			}
		} else {
			$this->template_assign( 'user_name', '' );
		}

		return $this->template_parse( 'display_login.tpl' );
	}

	function display_add_user( $user_name, $user_email, $user_password, $www_enabled, $permission_object ) {
		if( !$this->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		} elseif ( $this->checkWwwAdmin() ) {
			$user_properties  = $this->display_properties( '', $user_name, $user_email, $user_password, $www_enabled );
			$user_permissions = $this->display_permissions( $permission_object );

			$this->template_assign( 'user_properties',  $user_properties  );
			$this->template_assign( 'user_permissions', $user_permissions );
		} else {
			$this->TinderboxDS->addError( permission_denied );
			return $this->template_parse( 'user_admin.tpl' );
		}
		$this->template_assign( 'add', 1 );
		return $this->template_parse( 'user_admin.tpl' );
	}

	function display_modify_user( $first, $user_id, $user_name, $user_email, $user_password, $www_enabled, $permission_object ) {
		if( !$this->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		}

		$user = $this->TinderboxDS->getUserById( $user_id );
		if( $first == 1 ) {
			$user_name     = $user->getName();
			$user_email    = $user->getEmail();
			$www_enabled   = $user->getWwwEnabled();
			$all_hosts     = $this->moduleHosts->get_all_hosts();
			$all_builds    = $this->moduleBuilds->get_all_builds();
			foreach( $all_hosts as $host ) {
				$host = $host['host_id'];
				foreach( $all_builds as $build ) {
					$build = $build['build_id'];
					foreach( $this->TinderboxDS->getUserPermissions( $user->getId(), $host, 'builds', $build ) as $perm ) {
						$permission_object[$host][$build][$perm['User_Permission']] = 'on';
					}
				}
			}
		}

		if( !is_array( $permission_object ) ) {
			$permission_object[0][0][0] = 1;
		}
		if( $this->checkWwwAdmin() || ( $this->get_id() == $user->getId() ) ) {
			$user_properties  = $this->display_properties( $user_id, $user_name, $user_email, $user_password, $www_enabled );
			$user_permissions = $this->display_permissions( $permission_object );

			$this->template_assign( 'user_properties',  $user_properties  );
			$this->template_assign( 'user_permissions', $user_permissions );
		} else {
			$this->TinderboxDS->addError( permission_denied );
			return $this->template_parse( 'user_admin.tpl' );
		}
		$this->template_assign( 'modify', 1 );
		return $this->template_parse( 'user_admin.tpl' );
	}

	function display_permissions( $permission_object ) {
		$this->template_assign( 'all_hosts',         $this->moduleHosts->get_all_hosts() );
		$this->template_assign( 'all_builds',        $this->moduleBuilds->get_all_builds() );
		$this->template_assign( 'permission_object', $permission_object );
		$this->template_assign( 'www_admin',         $this->checkWwwAdmin() );
		return $this->template_parse( 'user_permissions.tpl' );
	}

	function display_properties( $user_id, $user_name, $user_email, $user_password, $www_enabled ) {
		$this->template_assign( 'user_id',       $user_id       );
		$this->template_assign( 'user_name',     $user_name     );
		$this->template_assign( 'user_email',    $user_email    );
		$this->template_assign( 'user_password', $user_password );
		$this->template_assign( 'www_enabled',   $www_enabled   );
		return $this->template_parse( 'user_properties.tpl' );
	}

	function action_user( $action, $user_id, $user_name, $user_email, $user_password, $www_enabled, $permission_object ) {
		if( !$this->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		} elseif( empty( $user_name ) ) {
			$this->TinderboxDS->addError( user_admin_user_name_empty );
			return '0';
		} elseif( $action == 'add' && !$this->checkWwwAdmin() ) {
			$this->TinderboxDS->addError( permission_denied );
			return '0';
		} elseif( $action != 'add' && ( !$this->checkWwwAdmin() && ( $this->get_id() != $user_id ) ) ) {
			$this->TinderboxDS->addError( permission_denied );
			return '0';
		}		

		$user = $this->TinderboxDS->getUserById( $user_id );

		if( $action == 'add' ) {
			if( is_object( $user ) && $user->getId() ) {
				$this->TinderboxDS->addError( user_admin_user_exists );
				return '0';
			} else {
				$user = new User();
			}
		} elseif( ( $action == 'delete' || $action == 'modify' ) && !is_object( $user ) || !$user->getId() ) {
			$this->TinderboxDS->addError( user_admin_user_not_exist );
			return '0';
		}
		
		switch( $www_enabled ) {
			case '1':	$www_enabled = 1; break;
			default:	$www_enabled = 0; break;
		}

		$user->setName( $user_name );
		$user->setEmail( $user_email );
		$user->setWwwEnabled( $www_enabled );
		if( $user_password ) {
			$user->setPassword( $this->TinderboxDS->cryptPassword( $user_password ) );
		}

		if( $action == 'add' ) {
			if( !$this->TinderboxDS->addUser( $user ) ) {
				return '0';
			}
			$user = $this->TinderboxDS->getUserByName( $user_name );
		} elseif( $action == 'modify' ) {
			if( !$this->TinderboxDS->updateUser( $user ) ) {
				return '0';
			}
			if( $this->checkWwwAdmin() ) {
				$this->TinderboxDS->deleteUserPermissions( $user );
			}
		} elseif( $action == 'delete' ) {
			if( !$this->TinderboxDS->deleteUser( $user ) ) {
				return '0';
			}
			return '1';
		}

		if( $this->checkWwwAdmin() && is_array( $permission_object ) ) {
			foreach( $permission_object as $host => $build_value ) {
				foreach( $build_value as $build => $permission_value ) {
					foreach( $permission_value as $permission => $enable_value ) {
						if( $enable_value == 'on' ) {
							if( !$this->TinderboxDS->addUserPermission( $user->getId(), $host, 'builds', $build, $permission ) ) {
								$this->TinderboxDS->deleteUser( $user );
								return '0';
							}
						}
					}
				}
			}
		}
		return '1';
	}

	function do_login( $username, $password ) {
		global $moduleSession;

		$user = $this->TinderboxDS->getUserByLogin( $username, $password );
		if( $user ) {
			if(  $user->getWwwEnabled() ) {
				$moduleSession->setAttribute( 'user', $user );
				return true;
			} else {
				$this->TinderboxDS->addError( user_login_not_enabled );
			}
		} else {
			$this->TinderboxDS->addError( user_login_wrong_data );
		}

		return false;
	}

	function do_logout() {
		global $moduleSession;

		$moduleSession->removeAttribute( 'user' );
		$moduleSession->destroy();

		return true;
	}

	function is_logged_in() {
		global $moduleSession;

		if( is_object( $moduleSession->getAttribute( 'user' ) ) && $moduleSession->getAttribute( 'user' )->getWwwEnabled() == 1 ) {
			return true;
		}
		return false;
	}

	function get_www_enabled() {
		global $moduleSession;

		$user = $this->TinderboxDS->getUserById( $moduleSession->getAttribute( 'user' )->getId() );
		if( is_object( $user ) ) {
			return $user->getWwwEnabled();
		}

		return false;
	}

	function get_id() {
		global $moduleSession;

		return $moduleSession->getAttribute( 'user' )->getId();
	}

	function get_all_users() {
		$all_users_raw = $this->TinderboxDS->getAllUsers();
		$all_users = array();
		foreach( $all_users_raw as $user ) {
			$all_users[] = array( 'user_id' => $user->getId(), 'user_name' => $user->getName() );
		}
		return $all_users;
	}

	function fetch_permissions( $host_id, $object_type, $object_id ) {
		global $moduleSession;

		if( $this->is_logged_in() ) {
			foreach( $this->TinderboxDS->getUserPermissions( $moduleSession->getAttribute( 'user' )->getId(), $host_id, $object_type, $object_id ) as $perm ) {
				$this->permissions[$host_id][$object_type][$object_id][$perm['User_Permission']] = 1;
			}
			$this->permissions[$host_id][$object_type][$object_id]['set'] = 1;
			return true;
		} else {
			return false;
		}
	}

	function get_permission( $host_id, $object_type, $object_id, $permission ) {
		if( !is_array( $this->permissions[$host_id][$object_type][$object_id] ) && $this->permissions[$host_id][$object_type][$object_id]['set'] != 1 ) {
			$this->fetch_permissions( $host_id, $object_type, $object_id );
		}
		return $this->permissions[$host_id][$object_type][$object_id][$permission];
	}

	function checkWwwAdmin() {
		return $this->get_permission( '0', 'users', $this->get_id(), 'IS_WWW_ADMIN' );
	}

	function checkPermAddQueue( $host_id, $object_type, $object_id ) {
		return $this->get_permission( $host_id, $object_type, $object_id, 'PERM_ADD_QUEUE' );
	}

	function checkPermModifyOwnQueue( $host_id, $object_type, $object_id ) {
		return $this->get_permission( $host_id, $object_type, $object_id, 'PERM_MODIFY_OWN_QUEUE' );
	}

	function checkPermDeleteOwnQueue( $host_id, $object_type, $object_id ) {
		return $this->get_permission( $host_id, $object_type, $object_id, 'PERM_DELETE_OWN_QUEUE' );
	}

	function checkPermPrioLower5( $host_id, $object_type, $object_id ) {
		return $this->get_permission( $host_id, $object_type, $object_id, 'PERM_PRIO_LOWER_5' );
	}

	function checkPermModifyOtherQueue(  $host_id,$object_type, $object_id ) {
		return $this->get_permission( $host_id, $object_type, $object_id, 'PERM_MODIFY_OTHER_QUEUE' );
	}

	function checkPermDeleteOtherQueue( $host_id, $object_type, $object_id ) {
		return $this->get_permission( $host_id, $object_type, $object_id, 'PERM_DELETE_OTHER_QUEUE' );
	}
}
?>
