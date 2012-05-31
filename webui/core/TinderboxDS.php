<?php
#-
# Copyright (c) 2004-2005 FreeBSD GNOME Team <freebsd-gnome@FreeBSD.org>
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
# $MCom: portstools/tinderbox/webui/core/TinderboxDS.php,v 1.62 2012/05/31 22:09:39 ade Exp $
#

require_once 'Build.php';
require_once 'BuildGroups.php';
require_once 'BuildPortsQueue.php';
require_once 'Config.php';
require_once 'Hooks.php';
require_once 'Jail.php';
require_once 'LogfilePattern.php';
require_once 'Port.php';
require_once 'PortsTree.php';
require_once 'PortFailPattern.php';
require_once 'PortFailReason.php';
require_once 'User.php';
require_once 'inc_ds.php';
require_once 'inc_tinderbox.php';

$objectMap = array(
	'Build'           => 'builds',
	'BuildGroups'     => 'build_groups',
	'BuildPortsQueue' => 'build_ports_queue',
	'LogfilePattern'  => 'logfile_patterns',
	'Config'          => 'config',
	'Jail'            => 'jails',
	'Port'            => 'ports',
	'PortsTree'       => 'ports_trees',
	'PortFailPattern' => 'port_fail_patterns',
	'PortFailReason'  => 'port_fail_reasons',
	'User'            => 'users',
	'Hooks'           => 'hooks',
	);

class TinderboxDS {
	public $db;
	public $error;
	public $packageSuffixCache; /* in use by getPackageSuffix() */

	function TinderboxDS() {
		global $DB_HOST, $DB_DRIVER, $DB_NAME, $DB_USER, $DB_PASS, $DB_PATH;

		# XXX: backwards compatibility
		if ( $DB_DRIVER == '' )
			$DB_DRIVER = 'mysql';

		$dsn = "$DB_DRIVER:host=${DB_HOST};dbname=${DB_NAME}";

		try {
			$this->db = new PDO( $dsn, $DB_USER, $DB_PASS, array( PDO::ATTR_PERSISTENT => true ) );
			$this->db->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_SILENT );
		} catch ( PDOException $e ) {
			die( "Tinderbox DS: Unable to connect to database: " . $e->getMessage(). "\n" );
		}
	}

	function start_transaction() {
		$this->db->beginTransaction();
	}

	function commit_transaction() {
		$this->db->commit();
	}

	function rollback_transaction() {
		$this->db->rollBack();
	}

	function getAllMaintainers() {
			  $query = "SELECT DISTINCT LOWER(port_maintainer)
									 AS port_maintainer
								   FROM ports where port_maintainer IS NOT NULL
							   ORDER BY LOWER(port_maintainer)";
		$rc = $this->_doQueryHashRef( $query, $results, array() );

		if ( !$rc ) {
			return array();
		}

		foreach( $results as $result )
			$data[] = $result['port_maintainer'];

		if ( empty( $data ) ) {
			return null;
		} else {
			return $data;
		}
	}

	function getAllPortsByPortID( $portid ) {
		$query = "SELECT p.*,
						 bp.build_id AS build_id,
						 bp.last_built AS last_built,
						 bp.last_status AS last_status,
						 bp.last_successful_built AS last_successful_built,
						 bp.last_failed_dependency AS last_failed_dependency,
						 bp.last_run_duration AS last_run_duration,
						 bp.last_built_version AS last_built_version,
					CASE bp.last_fail_reason
					  WHEN '__nofail__' THEN ''
					  ELSE bp.last_fail_reason
					END
					  AS last_fail_reason
					FROM ports p,
						 build_ports bp
				   WHERE p.port_id = bp.port_id
					 AND bp.port_id = ?";

		$rc = $this->_doQueryHashRef( $query, $results, array( $portid ) );

		if ( !$rc ) {
			return null;
		}

		$ports = $this->_newFromArray( 'Port', $results );

		return $ports;
	}


	function addUser( $user ) {
		$query = "INSERT INTO users
							  (user_name,user_email,user_password,user_www_enabled)
					   VALUES (?,?,?,?)";

		$rc = $this->_doQuery( $query, array( $user->getName(),$user->getEmail(),$user->getPassword(),$user->getWwwEnabled() ),$res );

		if ( !$rc ) {
			return false;
		}

		return true;
	}

	function deleteUser( $user ) {
		if( !$user->getId() || $this->deleteUserPermissions( $user, '' ) ) {
			if ( $user->getId() ) {
				$this->deleteBuildPortsQueueByUserId( $user );
			}
			$query = "DELETE FROM users
							WHERE user_name=?";

			$rc = $this->_doQuery( $query, array( $user->getName() ), $res );

			if ( !$rc ) {
				return false;
			}

			return true;
		}
		return false;
	}

	function updateUser( $user ) {
		$query = "UPDATE users
					 SET user_name=?,user_email=?,user_password=?,user_www_enabled=?
				   WHERE user_id=?";

		$rc = $this->_doQuery( $query, array( $user->getName(),$user->getEmail(),$user->getPassword(),$user->getWwwEnabled(),$user->getId() ), $res );

		if ( !$rc ) {
			return false;
		}

		return true;
	}

	function getUserByLogin( $username, $password ) {
		$hashPass = md5( $password );
		$query = "SELECT user_id,user_name,user_email,user_password,user_www_enabled
					FROM users
				   WHERE user_name=?
					 AND user_password=?";
		$rc = $this->_doQueryHashRef( $query, $results, array( $username,$hashPass ) );

		if ( !$rc ) {
			return null;
		}

		$user = $this->_newFromArray( 'User', $results );

		if ( !empty ( $user[0] ) ) {
			return $user[0];
		} else {
			return null;
		}
	}

	function getUserPermissions( $user_id, $object_type, $object_id ) {

		$query = "
			SELECT
			 CASE user_permission
			   WHEN 1 THEN 'IS_WWW_ADMIN'
			   WHEN 2 THEN 'PERM_ADD_QUEUE'
			   WHEN 3 THEN 'PERM_MODIFY_OWN_QUEUE'
			   WHEN 4 THEN 'PERM_DELETE_OWN_QUEUE'
			   WHEN 5 THEN 'PERM_PRIO_LOWER_5'
			   WHEN 6 THEN 'PERM_MODIFY_OTHER_QUEUE'
			   WHEN 7 THEN 'PERM_DELETE_OTHER_QUEUE'
			   ELSE 'PERM_UNKNOWN'
			 END
			   AS user_permission
			 FROM user_permissions
			WHERE user_id=?
			  AND user_permission_object_type=?
			  AND user_permission_object_id=?";

		$rc = $this->_doQueryHashRef( $query, $results, array( $user_id,$object_type,$object_id ) );

		if ( !$rc ) {
			return null;
		}

		return $results;
	}

	function deleteUserPermissions( $user, $object_type ) {

		$query = "
			DELETE FROM user_permissions
				  WHERE user_id=?";

		if ( $object_type )
			$query .= " AND user_permission_object_type=" . $this->db->quote( $object_type );

		$rc = $this->_doQuery( $query, array( $user->getId() ), $res );

		if ( !$rc ) {
			return false;
		}

		return true;
	}

	function addUserPermission( $user_id, $object_type, $object_id, $permission ) {

		switch( $permission ) {
//			case 'IS_WWW_ADMIN':			$permission = 1; break;   /* only configureable via shell */
			case 'PERM_ADD_QUEUE':			$permission = 2; break;
			case 'PERM_MODIFY_OWN_QUEUE':	$permission = 3; break;
			case 'PERM_DELETE_OWN_QUEUE':	$permission = 4; break;
			case 'PERM_PRIO_LOWER_5':		$permission = 5; break;
			case 'PERM_MODIFY_OTHER_QUEUE':	$permission = 6; break;
			case 'PERM_DELETE_OTHER_QUEUE':	$permission = 7; break;
			default:						return false;
		}

		$query = "
			INSERT INTO user_permissions
						(user_id,user_permission_object_type,user_permission_object_id,user_permission)
				 VALUES
						(?,?,?,?)";

		$rc = $this->_doQuery( $query, array( $user_id, $object_type, $object_id, $permission ), $res );

		if ( !$rc ) {
			return false;
		}

		return true;
	}

	function getBuildPortsQueueEntries( $build_id ) {
		$query = "SELECT build_ports_queue.*, builds.build_name AS build_name, users.user_name AS user_name
					FROM build_ports_queue, builds, users
				   WHERE build_ports_queue.build_id=?
					 AND builds.build_id = build_ports_queue.build_id
					 AND users.user_id = build_ports_queue.user_id
				ORDER BY priority ASC, build_ports_queue_id ASC";
		$rc = $this->_doQueryHashRef( $query, $results, array( $build_id ) );

		if ( !$rc ) {
			return null;
		}

		$build_ports_queue_entries = $this->_newFromArray( 'BuildPortsQueue', $results );

		return $build_ports_queue_entries;
	}

	function deleteBuildPortsQueueEntry( $entry_id ) {
		$query = "DELETE FROM build_ports_queue
						WHERE build_ports_queue_id=?";

		$rc = $this->_doQuery( $query, $entry_id, $res );

		if ( !$rc ) {
			return false;
		}

		return true;
	}

	function deleteBuildPortsQueueByUserId( $user ) {
		$query = "DELETE FROM build_ports_queue
						WHERE user_id=?";

		$rc = $this->_doQuery( $query, $user->getId(), $res );

		if ( !$rc ) {
			return false;
		}

		return true;
	}

	function createBuildPortsQueueEntry( $build_id, $priority, $port_directory, $user_id, $email_on_completion ) {
		switch( $email_on_completion ) {
			case '1':	$email_on_completion = 1; break;
			default:	$email_on_completion = 0; break;
		}

		$entries[] = array( 'build_id'            => $build_id,
							'priority'            => $priority,
							'port_directory'      => $port_directory,
							'user_id'             => $user_id,
							'enqueue_date'        => date("Y-m-d H:i:s", time()),
							'email_on_completion' => $email_on_completion,
							'status'              => 'ENQUEUED');

		$results = $this->_newFromArray( 'BuildPortsQueue', $entries );

		return $results[0];
	}

	function updateBuildPortsQueueEntry( $entry ) {

		$query = "UPDATE build_ports_queue
					 SET build_id=?, priority=?, email_on_completion=?, status=?
				   WHERE build_ports_queue_id=?";

		$rc = $this->_doQuery( $query, array( $entry->getBuildId(), $entry->getPriority(), $entry->getEmailOnCompletion(), $entry->getStatus(), $entry->getId() ), $res );

		if ( !$rc ) {
			return false;
		}

		return true;
	}

	function addBuildPortsQueueEntry( $entry ) {
		$query = "INSERT INTO build_ports_queue
							  (enqueue_date,build_id,priority,port_directory,user_id,email_on_completion,status)
					   VALUES
							  (?,?,?,?,?,?,?)";

		$rc = $this->_doQuery( $query, array( $entry->getEnqueueDate(), $entry->getBuildId(), $entry->getPriority(), $entry->getPortDirectory(), $entry->getUserId(), $entry->getEmailOnCompletion(), $entry->getStatus() ), $res );

		if ( !$rc ) {
			return false;
		}

		return true;
	}

	function getBuildPortsQueueEntryById( $id ) {
		$results = $this->getBuildPortsQueue( array( 'build_ports_queue_id' => $id ) );

		if ( is_null( $results ) ) {
			return null;
		}

		return $results[0];
	}

	function getPortsForBuild( $build, $sortby = 'port_directory', $port_name = '', $limit = 0 , $limit_offset = 0 ) {
		$sortbytable = 'bp';
		$sortbyqual = '';
		if ( $sortby == '' ) $sortby = 'port_directory';
		if ( $sortby == 'port_directory' ) $sortbytable = 'p';
		if ( $sortby == 'port_maintainer' ) $sortbytable = 'p';
		if ( $sortby == 'last_built' || $sortby == 'last_successful_built' ) {
			$sortbytable = 'bp';
			$sortby .= ' DESC';
		}
		$query = "SELECT p.port_id AS port_id,
						 p.port_directory AS port_directory,
						 REPLACE(p.port_maintainer, '@freebsd.org', '') as port_maintainer,
						 p.port_name AS port_name,
						 p.port_comment AS port_comment,
						 bp.last_built AS last_built,
						 bp.last_status AS last_status,
						 bp.last_successful_built AS last_successful_built,
						 bp.last_built_version AS last_built_version,
						 bp.last_failed_dependency AS last_failed_dependency,
						 bp.last_run_duration AS last_run_duration,
					CASE bp.last_fail_reason
					  WHEN '__nofail__' THEN ''
					  ELSE bp.last_fail_reason
					END
					  AS last_fail_reason
					FROM ports p,
						 build_ports bp
				   WHERE p.port_id = bp.port_id
					 AND bp.build_id=?";
		if ( $port_name )
			$query .= " AND p.port_name LIKE " . $this->db->quote( "%${port_name}%" );
		$query .= " ORDER BY " . $sortbytable . "." . substr( $this->db->quote( $sortby ), 1, strlen( $sortby ) );
		if ( $limit != 0 ) {
			$query .= " LIMIT " . substr( $this->db->quote( $limit ), 1, strlen( $sortby ) );
			$query .= " OFFSET " . substr( $this->db->quote( $limit_offset ), 1, strlen( $limit_offset ) );
		}

		$rc = $this->_doQueryHashRef( $query, $results, array( $build->getId() ) );

		if ( !$rc ) {
			return null;
		}

		$ports = $this->_newFromArray( 'Port', $results );

		return $ports;
	}

	function getLatestPorts( $build_id, $limit = '', $maintainer = '' ) {
		$query = "SELECT p.*,
						 bp.build_id AS build_id,
						 bp.last_built AS last_built,
						 bp.last_status AS last_status,
						 bp.last_successful_built AS last_successful_built,
						 bp.last_built_version AS last_built_version,
						 bp.last_failed_dependency AS last_failed_dependency,
						 bp.last_run_duration AS last_run_duration,
					CASE bp.last_fail_reason
					  WHEN '__nofail__' THEN ''
					  ELSE bp.last_fail_reason
					END
					  AS last_fail_reason
					FROM ports p,
						 build_ports bp
				   WHERE p.port_id = bp.port_id
					 AND bp.last_built IS NOT NULL ";
		if( $build_id )
			$query .= "AND bp.build_id=" . $this->db->quote( $build_id );
		if( $maintainer )
			$query .= " AND p.port_maintainer=" . $this->db->quote( $maintainer );
		$query .= " ORDER BY bp.last_built DESC ";
		if ( $limit )
			$query .= " LIMIT " . substr( $this->db->quote( $limit ), 1, strlen( $limit ) );

		$rc = $this->_doQueryHashRef( $query, $results, array() );

		if ( !$rc ) {
			return null;
		}

		$ports = $this->_newFromArray( 'Port', $results );

		return $ports;
	}

	function getBuildPorts( $port_id, $build_id ) {
		$query = "SELECT p.*,
						 bp.last_built AS last_built,
						 bp.last_status AS last_status,
						 bp.last_successful_built AS last_successful_built,
						 bp.last_failed_dependency AS last_failed_dependency,
						 bp.last_run_duration AS last_run_duration,
					CASE bp.last_fail_reason
					  WHEN '__nofail__' THEN ''
					  ELSE bp.last_fail_reason
					END
					  AS last_fail_reason
					FROM ports p,
						 build_ports bp
				   WHERE p.port_id = bp.port_id
					 AND bp.build_id=?
					 AND bp.port_id=?";

		$rc = $this->_doQueryHashRef( $query, $results, array( $build_id, $port_id ) );
		if ( !$rc ) {
			return null;
		}

		$ports = $this->_newFromArray( 'Port', $results );

		return $ports[0];
	}


	function getPortsByStatus( $build_id, $maintainer, $status, $notstatus, $limit = 0 , $limit_offset = 0, $sortby = 'last_built' ) {
		$sortbytable = 'bp';
		$sortbyqual = '';
		if ( $sortby == '' ) $sortby = 'port_directory';
		if ( $sortby == 'port_directory' ) $sortbytable = 'p';
		if ( $sortby == 'port_maintainer' ) $sortbytable = 'p';
		if ( $sortby == 'last_built' || $sortby == 'last_successful_built' ) {
			$sortbytable = 'bp';
			$sortby .= ' DESC';
		}
		$query = "SELECT p.*,
						 bp.build_id AS build_id,
						 bp.last_built AS last_built,
						 bp.last_status AS last_status,
						 bp.last_successful_built AS last_successful_built,
						 bp.last_built_version AS last_built_version,
						 bp.last_failed_dependency AS last_failed_dependency,
						 bp.last_run_duration AS last_run_duration,
					CASE bp.last_fail_reason
					  WHEN '__nofail__' THEN ''
					  ELSE bp.last_fail_reason
					END
					  AS last_fail_reason
					FROM ports p,
						 build_ports bp
				   WHERE p.port_id = bp.port_id ";

		if( $build_id )
			$query .= "AND bp.build_id=" . $this->db->quote( $build_id ) . " ";
		if( $status <> '' )
			$query .= "AND bp.last_status=" . $this->db->quote( $status ) . " ";
		if( $notstatus <> '' )
			$query .= "AND bp.last_status<>" . $this->db->quote( $notstatus ) . " AND bp.last_status<>'UNKNOWN' ";
		if( $maintainer )
			$query .= "AND p.port_maintainer=" . $this->db->quote( $maintainer ) . " ";
		$query .= " ORDER BY " . $sortbytable . "." . substr( $this->db->quote( $sortby ), 1, strlen( $sortby ) );
		if ( $limit != 0 ) {
			$query .= " LIMIT " . substr( $this->db->quote( $limit ), 1, strlen( $sortby ) );
			$query .= " OFFSET " . substr( $this->db->quote( $limit_offset ), 1, strlen( $limit_offset ) );
		}

		$rc = $this->_doQueryHashRef( $query, $results, array() );

		if ( !$rc ) {
			return null;
		}

		$ports = $this->_newFromArray( 'Port', $results );

		return $ports;
	}

	function getBuildStatsWithStatus( $build_id ) {
		$query = 'SELECT last_status, COUNT(*) AS c FROM build_ports WHERE build_id = ? GROUP BY last_status';
		$rc = $this->_doQueryHashRef( $query, $results, array( $build_id ) );
		if ( !$rc )
			return null;
		return $results;
	}


	function getBuildStats( $build_id ) {
		$query = 'SELECT COUNT(*) AS fails FROM build_ports WHERE last_status = \'FAIL\' AND build_id = ?';
		$rc = $this->_doQueryHashRef( $query, $results, array( $build_id ) );
		if ( !$rc )
			return null;
		return $results[0];
	}

	function getPortById( $id ) {
		$results = $this->getPorts( array( 'port_id' => $id ) );

		if ( is_null( $results ) || empty( $results ) ) {
			return null;
		}

		return $results[0];
	}

	function getPortByDirectory( $dir ) {
		$results = $this->getPorts( array( 'port_directory' => $dir ) );

		if ( is_null( $results ) ) {
			return null;
		}

		return $results[0];
	}

	function getCurrentPortForBuild( $build_id ) {
		$query = 'SELECT port_id AS id FROM build_ports WHERE build_id = ? AND currently_building = \'1\'';
		$rc = $this->_doQueryHashRef( $query, $results, array( $build_id ) );
		if ( !$rc )
			return null;

		if ( empty( $results ) ) {
			return null;
		}

		$port = $this->getPortById( $results[0]['id'] );

		return $port;
	}

	function addBuildGroupEntry( $build_group_name, $build_id ) {
                $query = "INSERT INTO build_groups
					(build_group_name, build_id)
					VALUES (?,?)";
                         
                $rc = $this->_doQuery( $query, array( $build_group_name, $build_id ), $res );

                if ( !$rc ) {
                        return false;
                }
                           
                return true;
        }

	function deleteBuildGroupEntry( $build_group_name, $build_id ) {
		$query = "DELETE FROM build_groups
						WHERE build_group_name=? AND build_id=?";

		$rc = $this->_doQuery( $query, array( $build_group_name, $build_id ), $res );

		if ( !$rc ) {
			return false;
		}

		return true;
	}

	function getObjects( $type, $params = array(), $orderby = "" ) {
		global $objectMap;

		if ( !isset( $objectMap[$type] ) ) {
			die( "Unknown object type, $type\n" );
		}

		$table = $objectMap[$type];
		$condition = '';

		$values = array();
		$conds = array();
		foreach ( $params as $field => $param ) {
			# Each parameter makes up and OR portion of a query.  Within
			# each parameter can be a hash reference that make up the AND
			# portion of the query.
			if ( is_array( $param ) ) {
				$ands = array();
				foreach ( $param as $andcond => $value ) {
					array_push( $ands, "$andcond=?" );
					array_push( $values, $value );
				}
				array_push( $conds, '(' . ( implode( ' AND ', $ands ) ) . ')' );
			} else {
				array_push( $conds, '(' . $field . '=?)' );
				array_push( $values, $param );
			}
		}

		$condition = implode( ' OR ', $conds );

		if ( $condition != '' ) {
			$query = "SELECT * FROM $table WHERE " . $condition;
		}
		else {
			$query = "SELECT * FROM $table";
		}

		if ( $orderby != "" ) {
			$query .= " ORDER BY " . $this->db->quote( $orderby );
		}

		$results = array();
		$rc = $this->_doQueryHashRef( $query, $results, $values );

		if ( !$rc ) {
			return null;
		}

		return $this->_newFromArray( $type, $results );
	}

	function getBuildByName( $name ) {
		$results = $this->getBuilds( array( 'build_name' => $name ) );

		if ( is_null( $results ) ) {
			return null;
		}

		return $results[0];
	}

	function getBuildById( $id ) {
		$results = $this->getBuilds( array( 'build_id' => $id ) );

		if ( is_null( $results ) ) {
			return null;
		}

		return $results[0];
	}

	function getJailById( $id ) {
		$results = $this->getJails( array( 'jail_id' => $id ) );

		if ( is_null( $results ) ) {
			return null;
		}

		return $results[0];
	}

	function getPortsTreeForBuild( $build ) {
		$portstree = $this->getPortsTreeById( $build->getPortsTreeId() );

		return $portstree;
	}

	function getPortsTreeByName( $name ) {
		$results = $this->getPortsTrees( array( 'ports_tree_name' => $name ) );
		if ( is_null( $results ) ) {
			return null;
		}

		return $results[0];
	}

	function getPortsTreeById( $id ) {
		$results = $this->getPortsTrees( array( 'ports_tree_id' => $id ) );

		if ( is_null( $results ) ) {
			return null;
		}

		return $results[0];
	}

	function getUserById( $id ) {
		$results = $this->getUsers( array( 'user_id' => $id ) );

		if ( is_null( $results ) ) {
			return null;
		}

		if ( isset( $results[0] ) ) {
			return $results[0];
		} else {
			return null;
		}
	}

	function getUserByName( $name ) {
		$results = $this->getUsers( array( 'user_name' => $name ) );

		if ( is_null( $results ) ) {
			return null;
		}

		if ( isset( $results[0] ) ) {
			return $results[0];
		} else {
			return null;
		}
	}

	function getConfig( $params = array() ) {
		return $this->getObjects( 'Config', $params );
	}

	function getHooks( $params = array() ) {
		return $this->getObjects( 'Hooks', $params );
	}

	function getBuildPortsQueue( $params = array() ) {
		return $this->getObjects( 'BuildPortsQueue', $params );
	}

	function getBuilds( $params = array(), $sortby = '' ) {
		return $this->getObjects( 'Build', $params, $sortby );
	}

	function getBuildGroups( $params = array(), $sortby = '' ) {
		return $this->getObjects( 'BuildGroups', $params, $sortby );
	}

	function getLogfilePatterns( $params = array() ) {
		return $this->getObjects( 'LogfilePattern', $params );
	}

	function getPorts( $params = array() ) {
		return $this->getObjects( 'Port', $params );
	}

	function getJails( $params = array() ) {
		return $this->getObjects( 'Jail', $params );
	}

	function getPortFailPatterns( $params = array() ) {
		return $this->getObjects( 'PortFailPattern', $params );
	}

	function getPortFailReasons( $params = array() ) {
		return $this->getObjects( 'PortFailReason', $params );
	}

	function getPortsTrees( $params = array() ) {
		return $this->getObjects( 'PortsTree', $params );
	}

	function getUsers( $params = array() ) {
		return $this->getObjects( 'User', $params );
	}

	function getAllConfig() {
		$config = $this->getConfig();

		return $config;
	}

	function getAllHooks() {
		$config = $this->getHooks();

		return $config;
	}

	function getAllBuilds( $sortby = '' ) {
		$builds = $this->getBuilds( array(), $sortby );

		return $builds;
	}

	function getAllBuildGroups( $sortby = '' ) {
		$buildgroups = $this->getBuildGroups( array(), $sortby );

		return $buildgroups;
	}

	function getAllLogfilePatterns() {
		$patterns = $this->getLogfilePatterns();

		return $patterns;
	}

	function getAllJails() {
		$jails = $this->getJails();

		return $jails;
	}

	function getAllPortFailPatterns() {
		$results = $this->getPortFailPatterns();

		return $results;
	}

	function getAllPortFailReasons() {
		$results = $this->getPortFailReasons();

		return $results;
	}

	function getAllPortsTrees() {
		$ports_trees = $this->getPortsTrees();

		return $ports_trees;
	}

	function getAllUsers() {
		$users = $this->getUsers();

		return $users;
	}

	function addError( $error ) {
		return $this->error[] = $error;
	}

	function getErrors() {
		return $this->error;
	}

	function _doQueryNumRows( $query, $params = array() ) {
		$rows = 0;
		$rc = $this->_doQuery( $query, $params, $res );

		if ( !$rc ) {
			return -1;
		}

		return count( $rc );
	}

	function _doQueryHashRef( $query, &$results, $params = array() ) {
		$rc = $this->_doQuery( $query, $params, $res );

		if ( !$rc ) {
			$results = null;
			return 0;
		}

		$results = $res;

		return 1;
	}

	function _doQuery( $query, $params, &$res ) {
		$sth = $this->db->prepare( $query );

		if ( !$sth ) {
			$this->addError( implode( $this->db->errorInfo(), ":" ) );
			return 0;
		}

		if ( !$sth->execute( $params ) ) {
			$this->addError( implode( $sth->errorInfo(), ":" ) );
			return 0;
		}

		$_res = $sth->fetchAll();

		if ( !is_null( $_res ) ) {
			$res = $_res;
		}

		return 1;
	}

	function _newFromArray( $type, $arr ) {
		$objects = array();

		foreach ( $arr as $item ) {
			eval( '$obj = new $type( $item );' );
			if ( !is_a( $obj, $type ) ) {
				return null;
			}
			array_push( $objects, $obj );
		}

		return $objects;
	}

	function destroy() {
		$this->db = null;
		$this->error = null;
	}

	function getPackageSuffix( $jail_id ) {
		if ( empty( $jail_id ) ) return '';
		/* Use caching to avoid a lot of SQL queries */
		if ( isset( $this->packageSuffixCache[$jail_id] ) ) {
			return $this->packageSuffixCache[$jail_id];
		} else {
			$jail = $this->getJailById( $jail_id );
			if ( substr( $jail->getName(), 0, 1 ) == '4' ) {
				$this->packageSuffixCache[$jail_id] = '.tgz';
				return '.tgz';
			} else {
				$this->packageSuffixCache[$jail_id] = '.tbz';
				return '.tbz';
			}
		}
	}
}
?>
