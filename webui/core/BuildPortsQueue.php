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
# $MCom: portstools/tinderbox/webui/core/BuildPortsQueue.php,v 1.10 2007/10/13 02:28:47 ade Exp $
#

    require_once 'TinderObject.php';

    class BuildPortsQueue extends TinderObject {

	function BuildPortsQueue($argv = array()) {
	    $object_hash = array(
                'build_ports_queue_id' => '',
		'enqueue_date' => '',
		'completion_date'  => '',
		'build_id' => '',
		'build_name' => '',
		'user_id' => '',
		'user_name' => '',
		'port_directory' => '',
		'priority' => '',
		'email_on_completion' => '',
		'status'  => ''
	    );

	    $this->TinderObject($object_hash, $argv);
	}

	function getId() {
	    return $this->build_ports_queue_id;
	}

	function getEnqueueDate() {
	    return $this->enqueue_date;
	}

	function getCompletionDate() {
	    return $this->completion_date;
	}

	function getEmailOnCompletion() {
	    return $this->_truth_array[$this->email_on_completion];
	}

	function getStatus() {
	    return $this->status;
	}

	function getPortDirectory() {
	    return $this->port_directory;
	}

	function getPriority() {
	    return $this->priority;
	}

	function getBuildId() {
	    return $this->build_id;
	}

	function getBuildName() {
	    return $this->build_name;
	}

	function getUserId() {
	    return $this->user_id;
	}

	function getUserName() {
	    return $this->user_name;
	}

	function getBuildPortsQueueId() {
	    return $this->build_ports_queue_id;
	}

	function setBuildId( $build_id ) {
	    return $this->build_id = $build_id;
	}

	function setPriority( $priority ) {
	    return $this->priority = $priority;
	}

	function setEmailOnCompletion( $email_on_completion ) {
            switch( $email_on_completion ) {
                case '1':    $email_on_completion = 1; break;
                default:     $email_on_completion = 0; break;
            }
	    return $this->email_on_completion = $email_on_completion;
	}

	function resetStatus() {
	    return $this->status='ENQUEUED';
	}
    }
?>
