<?php
#-
# Copyright (c) 2005 Oliver Lehmann <oliver@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#	notice, this list of conditions and the following disclaimer
# 2. Redistributions in binary form must reproduce the above copyright
#	notice, this list of conditions and the following disclaimer in the
#	documentation and/or other materials provided with the distribution.
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
# $MCom: portstools/tinderbox/webui/module/moduleTinderd.php,v 1.5 2005/11/08 23:46:54 oliver Exp $
#

require_once 'module/module.php';
require_once 'module/moduleBuilds.php';
require_once 'module/moduleHosts.php';
require_once 'module/moduleUsers.php';

class moduleTinderd extends module {

	function moduleTinderd() {
		$this->module();
		$this->moduleBuilds = new moduleBuilds();
		$this->moduleHosts  = new moduleHosts();
		$this->moduleUsers  = new moduleUsers();
	}

	function checkQueueEntryAccess( $entry, $mode ) {

		if( $this->moduleUsers->checkWwwAdmin() ) {
			return true;
		}

		switch ( $mode ) {
			case 'list':		return true;
						break;
			case 'add':		if(  $this->moduleUsers->checkPermAddQueue( $this->host_id, 'builds', $this->build_id ) ) {
							return true;
						} else {
							return false;
						}
						break;
			case 'modify':		if( $entry->getUserId() == $this->moduleUsers->get_id() &&
					            $this->moduleUsers->checkPermModifyOwnQueue( $this->host_id, 'builds', $this->build_id ) ) {
							return true;
						} elseif( $entry->getUserId() != $this->moduleUsers->get_id() &&
						          $this->moduleUsers->checkPermModifyOtherQueue( $this->host_id, 'builds', $this->build_id ) ) {
							return true;
						} else {
							return false;
						}
						break;
			case 'delete':		if( $entry->getUserId() == $this->moduleUsers->get_id() &&
						    $this->moduleUsers->checkPermDeleteOwnQueue( $this->host_id, 'builds', $this->build_id ) ) {
							return true;
						} elseif( $entry->getUserId() != $this->moduleUsers->get_id() &&
						          $this->moduleUsers->checkPermDeleteOtherQueue( $this->host_id, 'builds', $this->build_id ) ) {
							return true;
						} else {
							return false;
						}
						break;
			case 'priolower5':	if( $this->moduleUsers->checkPermPrioLower5( $this->host_id, 'builds', $this->build_id ) ) {
							return true;
						} else {
							return false;
						}
						break;
			default:
					return false;
		}

	}

	function create_prio_array( $entry ) {
		if( $this->checkQueueEntryAccess( $entry, 'priolower5' ) ) {
			$i = 1;
		} else {
			if( $entry->getPriority() < 5 ) {
				$prio[] = $entry->getPriority();
			}
			$i = 5;
		}

		for( ; $i <= 10; $i++ ) {
			$prio[] = $i;
		}

		return $prio;
	}

	function list_tinderd_queue( $host_id, $build_id ) {

		if( !$this->moduleUsers->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		} else {
			$this->template_assign( 'all_hosts',  $this->moduleHosts->get_all_hosts() );
			$this->template_assign( 'all_builds', $this->moduleBuilds->get_all_builds() );
			$this->template_assign( 'host_id',    $host_id );
			$this->template_assign( 'build_id',   $build_id );

			if( !empty( $host_id ) ) {
				$hosts[0]  = $this->TinderboxDS->getHostById( $host_id );
			} else {
				$hosts  = $this->TinderboxDS->getAllHosts();
			}

			if( !empty( $build_id ) ) {
				$builds[0] = $this->TinderboxDS->getBuildById( $build_id );
			} else {
				$builds = $this->TinderboxDS->getAllBuilds();
			}

			$i = 0;
			foreach( $hosts as $host ) {

				$this->host_id = $host->getId();

				foreach( $builds as $build ) {

					$this->build_id = $build->getId();

					if( is_object( $host ) && is_object( $build ) ) {
						$build_ports_queue_entries = $this->TinderboxDS->getBuildPortsQueueEntries( $this->host_id, $this->build_id );
						if( is_array( $build_ports_queue_entries ) && count( $build_ports_queue_entries ) > 0 ) {
							foreach( $build_ports_queue_entries as $build_ports_queue_entry ) {
								if( $this->checkQueueEntryAccess( $build_ports_queue_entry, 'list' ) ) {
									switch( $build_ports_queue_entry->getStatus() ) {
										case 'ENQUEUED':
											$status_field_class  = 'queue_entry_enqueued';
											break;
										case 'PROCESSING':
											$status_field_class  = 'queue_entry_processing';
											break;
										case 'SUCCESS':
											$status_field_class  = 'queue_entry_success';
											break;
										case 'FAIL':
											$status_field_class  = 'port_fail';
											break;
									}
									$entries[$i] = array( 'entry_id'  => $build_ports_queue_entry->getBuildPortsQueueId(),
									                      'directory' => $build_ports_queue_entry->getPortDirectory(),
									                      'priority'  => $build_ports_queue_entry->getPriority(),
									                      'build'     => $build_ports_queue_entry->getBuildName(),
									                      'host'      => $build_ports_queue_entry->getHostName(),
									                      'user'      => $build_ports_queue_entry->getUserName(),
											      'all_prio'  => $this->create_prio_array( $build_ports_queue_entry ),
											      'email_on_completion' => $build_ports_queue_entry->getEmailOnCompletion(),
											      'status_field_class'  => $status_field_class);

								}
								if( $this->checkQueueEntryAccess( $build_ports_queue_entry, 'modify' ) ) {
									$entries[$i]['modify'] = 1;
								}
								if( $this->checkQueueEntryAccess( $build_ports_queue_entry, 'delete' ) ) {
									$entries[$i]['delete'] = 1;
								}
								$i++;
							}
						}
					}
				}
			}

			if( !empty($entries) && is_array( $entries ) && count( $entries ) > 0 ) {
				$this->template_assign( 'entries', $entries );
				$this->template_assign( 'no_list', false );
			} else {
				$this->template_assign( 'no_list', true );
			}

			$this->template_assign( 'all_prio', array( 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ) );
			$this->template_assign( 'new_priority', 10 );

			return $this->template_parse( 'list_tinderd_queue.tpl' );
		}
	}

	function change_tinderd_queue( $action, $entry_id, $host_id, $build_id, $priority, $email_on_completion ) {

		if( !$this->moduleUsers->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		} else {
			$build_ports_queue_entry = $this->TinderboxDS->getBuildPortsQueueEntryById( $entry_id );
			$this->host_id  = $build_ports_queue_entry->getHostId();
			$this->build_id = $build_ports_queue_entry->getBuildId();
			if( $action == 'delete' ) {
				if( $this->checkQueueEntryAccess( $build_ports_queue_entry, 'delete' ) ) {
					$this->TinderboxDS->deleteBuildPortsQueueEntry( $entry_id );
				} else {
					$this->TinderboxDS->addError( build_ports_queue_not_allowed_to_delete );
				}
			} elseif( $action == 'reset status' ) {
				if( $this->checkQueueEntryAccess( $build_ports_queue_entry, 'modify' ) ) {
					$build_ports_queue_entry->resetStatus();
					$this->TinderboxDS->updateBuildPortsQueueEntry( $build_ports_queue_entry );
				} else {
					$this->TinderboxDS->addError( build_ports_queue_not_allowed_to_modify );
				}
			} elseif(  $action == 'save' ) {
				if( $this->checkQueueEntryAccess( $build_ports_queue_entry, 'modify' ) ) {
					$this->host_id  = $host_id;
					$this->build_id = $build_id;
					if( $this->checkQueueEntryAccess( $build_ports_queue_entry, 'modify' ) ) {
						if( $build_ports_queue_entry->getPriority() != $priority && $priority < 5 && !$this->checkQueueEntryAccess( $entry, 'priolower5' ) ) {
							$this->TinderboxDS->addError( build_ports_queue_priority_to_low );
						} else {
							$build_ports_queue_entry->setHostId( $host_id );
							$build_ports_queue_entry->setBuildId( $build_id );
							$build_ports_queue_entry->setPriority( $priority );
							$build_ports_queue_entry->setEmailOnCompletion( $email_on_completion );
							$this->TinderboxDS->updateBuildPortsQueueEntry( $build_ports_queue_entry );;
						}
					} else {
						$this->TinderboxDS->addError( build_ports_queue_not_allowed_to_modify );
					}
				} else {
					$this->TinderboxDS->addError( build_ports_queue_not_allowed_to_modify );
				}
			}
		}
		return;
	}

	function add_tinderd_queue( $action, $host_id, $build_id, $priority, $port_directory, $email_on_completion ) {

		if( !$this->moduleUsers->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		} else {
			$build_ports_queue_entry = $this->TinderboxDS->createBuildPortsQueueEntry( $host_id, $build_id, $priority, $port_directory, $this->moduleUsers->get_id(), $email_on_completion );
			$this->host_id  = $host_id;
			$this->build_id = $build_id;
			if( $action == 'add' ) {
				if( $this->checkQueueEntryAccess( $build_ports_queue_entry, 'add' ) ) {
					if( $priority < 5 && !$this->checkQueueEntryAccess( $entry, 'priolower5' ) ) {
						$this->template_assign( 'new_host_id', $host_id );
						$this->template_assign( 'new_build_id', $build_id );
						$this->template_assign( 'new_priority', $priority );
						$this->template_assign( 'new_port_directory', $port_directory );
						$this->template_assign( 'new_email_on_completion', $email_on_completion );
						$this->TinderboxDS->addError( build_ports_queue_priority_to_low );
					} else {
						$this->TinderboxDS->addBuildPortsQueueEntry( $build_ports_queue_entry );
					}
				} else {
					$this->template_assign( 'new_host_id', $host_id );
					$this->template_assign( 'new_build_id', $build_id );
					$this->template_assign( 'new_priority', $priority );
					$this->template_assign( 'new_port_directory', $port_directory );
					$this->TinderboxDS->addError( build_ports_queue_not_allowed_to_add );
				}
			}
		}
		return;
	}
}
?>
