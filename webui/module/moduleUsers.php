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
# $MCom: portstools/tinderbox/webui/module/moduleUsers.php,v 1.18 2007/10/13 02:28:48 ade Exp $
#

require_once 'module/module.php';
require_once 'module/moduleBuilds.php';

class moduleUsers extends module {

	var $permissions;

	function moduleUsers() {
		$this->module();
		$this->moduleBuilds = new moduleBuilds();
	}

	function display_login() {
		global $moduleSession;

		if( $this->is_logged_in() ) {
			$user = $moduleSession->getAttribute( 'user' );
			$this->template_assign( 'user_name', $user->getName() );
			$this->template_assign( 'user_id',   $user->getId() );
			if( $this->checkWwwAdmin() ) {
				$this->template_assign( 'is_www_admin', true );
				$this->template_assign( 'all_users', $this->get_all_users() );
			} else {
				$this->template_assign( 'is_www_admin', false );
			}
		} else {
			$this->template_assign( 'user_name', '' );
		}

		return $this->template_parse( 'display_login.tpl' );
	}

	function display_add_user( $user_name, $user_email, $user_password, $www_enabled ) {
		if( !$this->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		} elseif ( $this->checkWwwAdmin() ) {
			$user_properties  = $this->display_properties( '', $user_name, $user_email, $user_password, $www_enabled );

			$this->template_assign( 'user_properties',  $user_properties  );
		} else {
			$this->TinderboxDS->addError( permission_denied );
			return $this->template_parse( 'user_admin.tpl' );
		}
		$this->template_assign( 'add',    true  );
		$this->template_assign( 'modify', false );
		return $this->template_parse( 'user_admin.tpl' );
	}

	function display_modify_user( $first, $user_id, $user_name, $user_email, $user_password, $www_enabled ) {
		if( !$this->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		}

		$user = $this->TinderboxDS->getUserById( $user_id );
		if( $first == 1 ) {
			$user_name     = $user->getName();
			$user_email    = $user->getEmail();
			$www_enabled   = $user->getWwwEnabled();
			$all_builds    = $this->moduleBuilds->get_all_builds();
		}

		if( $this->checkWwwAdmin() || ( $this->get_id() == $user->getId() ) ) {
			$user_properties  = $this->display_properties( $user_id, $user_name, $user_email, $user_password, $www_enabled );

			$this->template_assign( 'user_properties',  $user_properties  );
		} else {
			$this->TinderboxDS->addError( permission_denied );
			return $this->template_parse( 'user_admin.tpl' );
		}
		$this->template_assign( 'add',    false );
		$this->template_assign( 'modify', true  );
		return $this->template_parse( 'user_admin.tpl' );
	}

	function display_properties( $user_id, $user_name, $user_email, $user_password, $www_enabled ) {
		$this->template_assign( 'user_id',       $user_id       );
		$this->template_assign( 'user_name',     $user_name     );
		$this->template_assign( 'user_email',    $user_email    );
		$this->template_assign( 'user_password', $user_password );
		$this->template_assign( 'www_enabled',   $www_enabled   );
		$this->template_assign( 'www_admin',     $this->checkWwwAdmin() );
		return $this->template_parse( 'user_properties.tpl' );
	}

	function action_user( $action, $user_id, $user_name, $user_email, $user_password, $www_enabled ) {
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

		switch( $action ) {
			case 'add':	$user = new User();
					$user2 = $this->TinderboxDS->getUserByName( $user_name );
					if( is_object( $user2 ) && $user2->getId() ) {
						$this->TinderboxDS->addError( user_admin_user_exists." (".$user_name.")" );
						return '0';
					}
					unset( $user2 );
					break;
			case 'modify':	$user = $this->TinderboxDS->getUserById( $user_id );
					if( !is_object( $user ) || !$user->getId() ) {
						$this->TinderboxDS->addError( user_admin_user_not_exist );
						return '0';
					}
					if( $user_name != $user->getName() ) {
						if( !$this->checkWwwAdmin() ) {
							$this->TinderboxDS->addError( user_admin_user_name_changed );
							return '0';
						} else {
							$user2 = $this->TinderboxDS->getUserByName( $user_name );
							if( is_object( $user2 ) && $user2->getId() ) {
								$this->TinderboxDS->addError( user_admin_user_exists." (".$user_name.")" );
								return '0';
							}
							unset( $user2 );
						}
					}
					break;
			case 'delete':	$user = $this->TinderboxDS->getUserById( $user_id );
					if( !is_object( $user ) || !$user->getId() ) {
						$this->TinderboxDS->addError( user_admin_user_not_exist );
						return '0';
					}
					break;
			default:	return '0';
					break;
		}

		switch( $www_enabled ) {
			case '1':	$www_enabled = 1; break;
			default:	$www_enabled = 0; break;
		}

		$user->setName( $user_name );
		$user->setEmail( $user_email );
		$user->setWwwEnabled( $www_enabled );
		if( $user_password ) {
			$user->setPassword( cryptPassword( $user_password ) );
		}

		$this->TinderboxDS->start_transaction();

		switch( $action ) {
			case 'add':	if( !$this->TinderboxDS->addUser( $user ) ) {
						$this->TinderboxDS->rollback_transaction();
						return '0';
					}
					$user = $this->TinderboxDS->getUserByName( $user_name );
					break;
			case 'modify':	if( !$this->TinderboxDS->updateUser( $user ) ) {
						$this->TinderboxDS->rollback_transaction();
						return '0';
					}
					if( $this->checkWwwAdmin() && !$this->TinderboxDS->deleteUserPermissions( $user, 'builds' ) ) {
						$this->TinderboxDS->rollback_transaction();
						return '0';
					}
					break;
			case 'delete':	if( !$this->TinderboxDS->deleteUser( $user ) ) {
						$this->TinderboxDS->rollback_transaction();
						return '0';
					} else {
						$this->TinderboxDS->commit_transaction();
						return '1';
					}
					break;
		}

		$this->TinderboxDS->commit_transaction();
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

		$user = $moduleSession->getAttribute( 'user' );

		if( is_object( $user ) && $user->getWwwEnabled() == 1 ) {
			return true;
		}
		return false;
	}

	function get_www_enabled() {
		global $moduleSession;
		$user = $moduleSession->getAttribute( 'user' );

		$userobj = $this->TinderboxDS->getUserById( $user->getId() );
		if( is_object( $userobj ) ) {
			return $userobj->getWwwEnabled();
		}

		return false;
	}

	function get_id() {
		global $moduleSession;
		$user = $moduleSession->getAttribute( 'user' );

		return $user->getId();
	}

	function get_all_users() {
		$all_users_raw = $this->TinderboxDS->getAllUsers();
		$all_users = array();
		foreach( $all_users_raw as $user ) {
			$all_users[] = array( 'user_id' => $user->getId(), 'user_name' => $user->getName() );
		}
		return $all_users;
	}

	function fetch_permissions( $object_type, $object_id ) {
		global $moduleSession;

		if( $this->is_logged_in() ) {
			$user = $moduleSession->getAttribute( 'user' );
			foreach( $this->TinderboxDS->getUserPermissions( $user->getId(), $object_type, $object_id ) as $perm ) {
				$this->permissions[$object_type][$object_id][$perm['user_permission']] = 1;
			}
			$this->permissions[$object_type][$object_id]['set'] = 1;
			return true;
		} else {
			return false;
		}
	}

	function get_permission( $object_type, $object_id, $permission ) {
		if( !is_array( $this->permissions[$object_type][$object_id] ) && !isset( $this->permissions[$object_type][$object_id]['set'] ) ) {
			$this->fetch_permissions( $object_type, $object_id );
		}
		if( isset( $this->permissions[$object_type][$object_id][$permission] ) ) {
			return true;
		} else {
			return false;
		}
	}

	function checkWwwAdmin() {
		return $this->get_permission( 'users', $this->get_id(), 'IS_WWW_ADMIN' );
	}
}

	function checkPermAddQueue( $object_type, $object_id ) {
		return $this->get_permission( $object_type, $object_id, 'PERM_ADD_QUEUE' );
	}

	function checkPermModifyOwnQueue( $object_type, $object_id ) {
		return $this->get_permission( $object_type, $object_id, 'PERM_MODIFY_OWN_QUEUE' );
	}

	function checkPermDeleteOwnQueue( $object_type, $object_id ) {
		return $this->get_permission( $object_type, $object_id, 'PERM_DELETE_OWN_QUEUE' );
	}

	function checkPermPrioLower5( $object_type, $object_id ) {
		return $this->get_permission( $object_type, $object_id, 'PERM_PRIO_LOWER_5' );
	}

	function checkPermModifyOtherQueue( $object_type, $object_id )
 {
		return $this->get_permission( $object_type, $object_id, 'PERM_MODIFY_OTHER_QUEUE' );
	}

	function checkPermDeleteOtherQueue( $object_type, $object_id )
 {
		return $this->get_permission( $object_type, $object_id, 'PERM_DELETE_OTHER_QUEUE' );
	}

?>
