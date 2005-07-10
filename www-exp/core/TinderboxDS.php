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
# $MCom: portstools/tinderbox/www-exp/core/TinderboxDS.php,v 1.2 2005/07/10 07:39:18 oliver Exp $
#

    require_once 'DB.php';
    require_once 'Build.php';
    require_once 'BuildPortsQueue.php';
    require_once 'Host.php';
    require_once 'Jail.php';
    require_once 'Port.php';
    require_once 'PortsTree.php';
    require_once 'User.php';
    require_once 'ds.inc';
    require_once 'tinderbox.inc';

    $objectMap = array(
        "Build" => "builds",
        "BuildPortsQueue" => "build_ports_queue",
        "Host"  => "hosts",
        "Jail"  => "jails",
        "Port"  => "ports",
        "PortsTree" => "ports_trees",
        "User"  => "users",
    );

    class TinderboxDS {
        var $db;
        var $error;
        var $packageSuffixCache; /* in use by getPackageSuffix() */

        function TinderboxDS() {
            global $DB_HOST, $DB_NAME, $DB_USER, $DB_PASS;

            $dsn = "mysql://$DB_USER:$DB_PASS@$DB_HOST/$DB_NAME";

            $this->db = DB::connect($dsn);

            if (DB::isError($this->db)) {
                die ("Tinderbox DS: Unable to initialize datastore: " . $this->db->getMessage() . "\n");
            }

            $this->db->setFetchMode(DB_FETCHMODE_ASSOC);
            $this->db->setOption('persistent', true);
        }

        function getAllMaintainers() {
            $query = "SELECT DISTINCT LOWER(port_maintainer) AS port_maintainer FROM ports where port_maintainer IS NOT NULL ORDER BY LOWER(port_maintainer)";
            $rc = $this->_doQueryHashRef($query, $results, array());

            if (!$rc) {
                return array();
            }

            foreach($results as $result)
                $data[]=$result['port_maintainer'];

            return $data;
        }

        function getAllPortsByPortID($portid) {
            $query = "SELECT ports.*,build_ports.Build_Id,build_ports.Last_Built,build_ports.Last_Status,build_ports.Last_Successful_Built,Last_Built_Version FROM ports,build_ports WHERE ports.Port_Id = build_ports.Port_Id AND build_ports.Port_Id=$portid";
            $rc = $this->_doQueryHashRef($query, $results, array());

            if (!$rc) {
                return null;
            }

            $ports = $this->_newFromArray("Port", $results);

            return $ports;
        }


        function addUser($user) {
            $query = "INSERT INTO users
                         (User_Name,User_Email,User_Password,User_Www_Enabled)
                      VALUES
                         (?,?,?,?)";

            $rc = $this->_doQuery($query, array($user->getName(),$user->getEmail(),$user->getPassword(),$user->getWwwEnabled()),$res);

            if (!$rc) {
                return false;
            }

            return true;
        }

        function deleteUser($user) {
            if( !$user->getId() || $this->deleteUserPermissions($user) ) {
                    if( $user->getId()) {
                        $this->deleteBuildPortsQueueByUserId($user);
                }
                $query = "DELETE FROM users
                                WHERE User_Name=?";

                $rc = $this->_doQuery($query, array($user->getName()),$res);

                if (!$rc) {
                     return false;
                }

                return true;
            }
            return false;
        }

        function updateUser($user) {
            $query = "UPDATE users
                         SET User_Name=?,User_Email=?,User_Password=?,User_Www_Enabled=?
                       WHERE User_Id=?";

            $rc = $this->_doQuery($query, array($user->getName(),$user->getEmail(),$user->getPassword(),$user->getWwwEnabled(),$user->getId()),$res);

            if (!$rc) {
                return false;
            }

            return true;
        }

        function getUserByLogin($username,$password) {
            $query = "SELECT User_Id,User_Name,User_Email,User_Password,User_Www_Enabled FROM users WHERE User_Name=? AND User_Password=PASSWORD(?)";
            $rc = $this->_doQueryHashRef($query, $results, array($username,$password));

            if (!$rc) {
                return null;
            }

            $user = $this->_newFromArray("User", $results);

            return $user[0];
        }

        function getUserPermissions($user_id,$host_id,$object_type,$object_id) {

            $query = "
                SELECT
                CASE User_Permission
                   WHEN 1 THEN 'IS_WWW_ADMIN'
                   WHEN 2 THEN 'PERM_ADD_QUEUE'
                   WHEN 3 THEN 'PERM_MODIFY_OWN_QUEUE'
                   WHEN 4 THEN 'PERM_DELETE_OWN_QUEUE'
                   WHEN 5 THEN 'PERM_PRIO_LOWER_5'
                   WHEN 6 THEN 'PERM_MODIFY_OTHER_QUEUE'
                   WHEN 7 THEN 'PERM_DELETE_OTHER_QUEUE'
                   ELSE 'PERM_UNKNOWN'
                END
                   AS User_Permission
                 FROM user_permissions
                WHERE User_Id=?
                  AND Host_Id=?
                  AND User_Permission_Object_Type=?
                  AND User_Permission_Object_Id=?";

            $rc = $this->_doQueryHashRef($query, $results, array($user_id,$host_id,$object_type,$object_id));

            if (!$rc) {
                return null;
            }

            return $results;
        }

        function deleteUserPermissions($user) {

            $query = "
                DELETE FROM user_permissions
                      WHERE User_Id=?";

            $rc = $this->_doQuery($query, array($user->getId()), $res);

            if (!$rc) {
                return false;
            }

            return true;
        }

        function addUserPermission($user_id,$host_id,$object_type,$object_id,$permission) {

            switch( $permission ) {
//              case 'IS_WWW_ADMIN':             $permission = 1; break;   /* only configureable via shell */
                case 'PERM_ADD_QUEUE':           $permission = 2; break;
                case 'PERM_MODIFY_OWN_QUEUE':    $permission = 3; break;
                case 'PERM_DELETE_OWN_QUEUE':    $permission = 4; break;
                case 'PERM_PRIO_LOWER_5':        $permission = 5; break;
                case 'PERM_MODIFY_OTHER_QUEUE':  $permission = 6; break;
                case 'PERM_DELETE_OTHER_QUEUE':  $permission = 7; break;
            }

            $query = "
                INSERT INTO user_permissions
                    (User_Id,Host_Id,User_Permission_Object_Type,User_Permission_Object_Id,User_Permission)
                   VALUES
                    (?,?,?,?,?)";

            $rc = $this->_doQuery($query, array($user_id,$host_id,$object_type,$object_id,$permission), $res);

            if (!$rc) {
                return false;
            }

            return true;
        }

        function getBuildPortsQueueEntries($host_id,$build_id) {
            $query = "SELECT build_ports_queue.*, builds.Build_Name Build_Name, users.User_Name User_Name, hosts.Host_Name Host_Name
                        FROM build_ports_queue, builds, users, hosts
                       WHERE build_ports_queue.Host_Id=?
                         AND build_ports_queue.Build_Id=?
                         AND builds.Build_Id = build_ports_queue.Build_Id
                         AND users.User_Id = build_ports_queue.User_Id
                         AND hosts.Host_Id = build_ports_queue.Host_Id
                    ORDER BY Priority";
            $rc = $this->_doQueryHashRef($query, $results, array($host_id,$build_id));

            if (!$rc) {
                return null;
            }

            $build_ports_queue_entries = $this->_newFromArray("BuildPortsQueue", $results);

            return $build_ports_queue_entries;
        }

        function deleteBuildPortsQueueEntry($entry_id) {
            $query = "DELETE FROM build_ports_queue
                            WHERE Build_Ports_Queue_Id=?";

            $rc = $this->_doQuery($query, $entry_id, $res);

            if (!$rc) {
                return false;
            }

            return true;
        }

        function deleteBuildPortsQueueByUserId($user) {
            $query = "DELETE FROM build_ports_queue
                            WHERE User_Id=?";

            $rc = $this->_doQuery($query, $user->getId(), $res);

            if (!$rc) {
                return false;
            }

            return true;
        }

        function updateBuildPortsQueueEntry($entry_id,$host_id,$build_id,$priority) {
            $query = "UPDATE build_ports_queue
                         SET Host_Id=?, Build_id=?, Priority=?
                       WHERE Build_Ports_Queue_Id=?";

            $rc = $this->_doQuery($query, array($host_id,$build_id,$priority,$entry_id), $res);

            if (!$rc) {
                return false;
            }

            return true;
        }

        function createBuildPortsQueueEntry($host_id,$build_id,$priority,$port_directory,$user_id) {
            $entries[] = array('Host_Id'        => $host_id,
                               'Build_Id'       => $build_id,
                               'Priority'       => $priority,
                               'Port_Directory' => $port_directory,
                               'User_Id'        => $user_id);

            $results = $this->_newFromArray("BuildPortsQueue",$entries);

            return $results[0];
        }

        function addBuildPortsQueueEntry($entry) {
            $query = "INSERT INTO build_ports_queue
                         (Host_Id,Build_id,Priority,Port_Directory,User_id)
                      VALUES
                         (?,?,?,?,?)";

            $rc = $this->_doQuery($query, array($entry->getHostId(),$entry->getBuildId(),$entry->getPriority(),$entry->getPortDirectory(),$entry->getUserId()), $res);

            if (!$rc) {
                return false;
            }

            return true;
        }

        function getPortsForBuild($build) {
            $query = "SELECT ports.*,build_ports.Last_Built,build_ports.Last_Status,build_ports.Last_Successful_Built,Last_Built_Version FROM ports,build_ports WHERE ports.Port_Id = build_ports.Port_Id AND Build_Id=? ORDER BY Port_Directory";
            $rc = $this->_doQueryHashRef($query, $results, $build->getId());

            if (!$rc) {
                return null;
            }

            $ports = $this->_newFromArray("Port", $results);

            return $ports;
        }

        function getLatestPorts($build_id,$limit="") {
            $query = "SELECT ports.*,build_ports.Build_Id,build_ports.Last_Built,build_ports.Last_Status,build_ports.Last_Successful_Built,Last_Built_Version FROM ports,build_ports WHERE ports.Port_Id = build_ports.Port_Id ";
            if($build_id)
                 $query .= "AND Build_Id=$build_id ";
            $query .= " ORDER BY Last_Built DESC ";
            if($limit)
                 $query .= " LIMIT $limit";

            $rc = $this->_doQueryHashRef($query, $results, array());

            if (!$rc) {
                return null;
            }

            $ports = $this->_newFromArray("Port", $results);

            return $ports;
        }

        function getPortsByStatus($build_id,$maintainer,$status) {
            $query = "SELECT ports.*,build_ports.Build_Id,build_ports.Last_Built,build_ports.Last_Status,build_ports.Last_Successful_Built,Last_Built_Version FROM ports,build_ports WHERE ports.Port_Id = build_ports.Port_Id ";
            if($build_id)
                 $query .= "AND Build_Id=$build_id ";
            if($status)
                 $query .= "AND Last_Status='$status' ";
            if($maintainer)
                 $query .= "AND Port_Maintainer='$maintainer'";
            $query .= " ORDER BY Last_Built DESC ";

            $rc = $this->_doQueryHashRef($query, $results, array());

            if (!$rc) {
                return null;
            }

            $ports = $this->_newFromArray("Port", $results);

            return $ports;
        }


        function getBuildStats($build_id) {
            $query = "SELECT SUM(IF(Last_Status = \"FAIL\", 1, 0)) AS fails FROM build_ports WHERE Build_Id = ?";
            $rc = $this->_doQueryHashRef($query, $results, $build_id);
            if (!$rc) return null;
            return $results[0];
        }

        function getPortById($id) {
            $results = $this->getPorts(array( 'Port_Id' => $id ));

            if (is_null($results)) {
                return null;
            }

            return $results[0];
        }

        function getObjects($type, $params = array()) {
            global $objectMap;

            if (!isset($objectMap[$type])) {
                die("Unknown object type, $type\n");
            }

            $table = $objectMap[$type];
            $condition = "";

            $values = array();
            $conds = array();
            foreach ($params as $field => $param) {
                # Each parameter makes up and OR portion of a query.  Within
                # each parameter can be a hash reference that make up the AND
                # portion of the query.
                if (is_array($param)) {
                    $ands = array();
                    foreach ($param as $andcond => $value) {
                        array_push($ands, "$andcond=?");
                        array_push($values, $value);
                    }
                    array_push($conds, "(" . (implode(" AND ", $ands)) . ")");
                } else {
                    array_push($conds, "(" . $field . "=?)");
                    array_push($values, $param);
                }
            }

            $condition = implode(" OR ", $conds);

            if ($condition != "") {
                $query = "SELECT * FROM $table WHERE $condition";
            }
            else {
                $query = "SELECT * FROM $table";
            }

            $results = array();
            $rc = $this->_doQueryHashRef($query, $results, $values);

            if (!$rc) {
                return null;
            }

            return $this->_newFromArray($type, $results);
        }

        function getBuildByName($name) {
            $results = $this->getBuilds(array( 'Build_Name' => $name ));

            if (is_null($results)) {
                return null;
            }

            return $results[0];
        }

        function getBuildById($id) {
            $results = $this->getBuilds(array( 'Build_Id' => $id ));

            if (is_null($results)) {
                return null;
            }

            return $results[0];
        }

        function getBuildPortsQueueEntryById($id) {
            $results = $this->getBuildPortsQueue(array( 'Build_Ports_Queue_Id' => $id ));

            if (is_null($results)) {
                 return null;
            }

            return $results[0];
        }

        function getHostById($id) {
            $results = $this->getHosts(array( 'Host_Id' => $id ));

            if (is_null($results)) {
                return null;
            }

            return $results[0];
        }

        function getJailById($id) {
            $results = $this->getJails(array( 'Jail_Id' => $id ));

            if (is_null($results)) {
                return null;
            }

            return $results[0];
        }

        function getPortsTreeForBuild($build) {
            $portstree = $this->getPortsTreeById($build->getPortsTreeId());

            return $portstree;
        }

        function getPortsTreeByName($name) {
             $results = $this->getPortsTrees(array( 'Ports_Tree_Name' => $name ));
             if (is_null($results)) {
                 return null;
             }

             return $results[0];
        }

        function getPortsTreeById($id) {
            $results = $this->getPortsTrees(array( 'Ports_Tree_Id' => $id ));

            if (is_null($results)) {
                 return null;
            }

            return $results[0];
        }

        function getUserById($id) {
            $results = $this->getUsers(array( 'User_Id' => $id ));

            if (is_null($results)) {
                return null;
            }

            return $results[0];
        }

        function getUserByName($name) {
            $results = $this->getUsers(array( 'User_Name' => $name ));

            if (is_null($results)) {
                return null;
            }

            return $results[0];
        }

        function getBuilds($params = array()) {
            return $this->getObjects("Build", $params);
        }

        function getBuildPortsQueue($params = array()) {
            return $this->getObjects("BuildPortsQueue", $params);
        }

        function getHosts($params = array()) {
            return $this->getObjects("Host", $params);
        }

        function getJails($params = array()) {
            return $this->getObjects("Jail", $params);
        }

        function getPortsTrees($params = array()) {
            return $this->getObjects("PortsTree", $params);
        }

        function getUsers($params = array()) {
            return $this->getObjects("User", $params);
        }

        function getAllBuilds() {
            $builds = $this->getBuilds();

            return $builds;
        }

        function getAllHosts() {
            $hosts = $this->getHosts();

            return $hosts;
        }

        function getAllJails() {
            $jails = $this->getJails();

            return $jails;
        }

        function getAllUsers() {
            $users = $this->getUsers();

            return $users;
        }

        function addError($error) {
             return $this->error[] = $error;
        }

        function getErrors() {
             return $this->error;
        }

        function _doQueryNumRows($query, $params = array()) {
            $rows = 0;
            $rc = $this->_doQuery($query, $params, $res);

            if (!$rc) {
                return -1;
            }

            if ($res->numRows() > -1) {
                $rows = $res->numRows();
            }
            else {
                while($res->fetchRow()) {
                    $rows++;
                }
            }

            $res->free();

            return $rows;
        }

        function _doQueryHashRef($query, &$results, $params = array()) {
            $rc = $this->_doQuery($query, $params, $res);

            if (!$rc) {
                $results = null;
                return 0;
            }

            $results = array();
            while ($row = $res->fetchRow()) {
                array_push($results, $row);
            }

            $res->free();

            return 1;
        }

        function _doQuery($query, $params, &$res) {
            $sth = $this->db->prepare($query);

            if (DB::isError($this->db)) {
                $this->addError($this->db->getMessage());
                return 0;
            }

            if (count($params)) {
                $_res = $this->db->execute($sth, $params);
            }
            else {
                $_res = $this->db->execute($sth);
            }

            if (DB::isError($_res)) {
                $this->addError($_res->getMessage());
                return 0;
            }

            if (!is_null($_res)) {
                $res = $_res;
            }
            else {
                $res->free();
            }

            return 1;
        }

        function _newFromArray($type, $arr) {
            $objects = array();

            foreach ($arr as $item) {
                eval('$obj = new $type($item);');
                if (!is_a($obj, $type)) {
                    return null;
                }
                array_push($objects, $obj);
            }

            return $objects;
        }

        function destroy() {
            $this->db->disconnect();
            $this->error = null;
        }

        function cryptPassword($password) {
            $query = "SELECT PASSWORD(?) PASSWORD FROM DUAL";

            $rc = $this->_doQuery($query, array($password), &$res);

            if (!$rc) {
                return null;
            }

            $password = $res->fetchRow();
            return $password['PASSWORD'];
        }

        function getPackageSuffix($jail_id) {
            if (empty($jail_id)) return "";
            /* Use caching to avoid a lot of SQL queries */
            if ($this->packageSuffixCache[$jail_id]) {
                return $this->packageSuffixCache[$jail_id];
            } else {
                $jail = $this->getJailById($jail_id);
                if (substr($jail->getName(), 0, 1) <= "4") {
                        $this->packageSuffixCache[$jail_id] = ".tgz";
                        return ".tgz";
                } else {
                        $this->packageSuffixCache[$jail_id] = ".tbz";
                        return ".tbz";
                }

            }
        }

        /* formatting functions */

         function prettyDatetime($input) {
            if (ereg("[0-9]{14}", $input)) {
                /* timestamp */
                return substr($input,0,4)."-".substr($input,4,2)."-".substr($input,6,2)." ".substr($input,8,2).":".substr($input,10,2).":".substr($input,12,2);
            } elseif (ereg("[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}", $input)) {
                /* datetime */
                if ($input == "0000-00-00 00:00:00") {
                    return "";
                } else {
                    return $input;
                }
            } else {
                return $input;
            }
        }

        function prettyEmail($input) {
            return str_replace("@FreeBSD.org", "", $input);
        }

   }
?>
