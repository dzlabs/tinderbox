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
# $MCom: portstools/tinderbox/webui/module/moduleTinderd.php,v 1.18 2010/04/29 16:26:29 beat Exp $
#

require_once 'module/module.php';
require_once 'module/moduleBuilds.php';
require_once 'module/moduleUsers.php';

class moduleTinderd extends module {

	function moduleTinderd( $TinderboxDS, $moduleBuilds, $moduleUsers ) {
		$this->module( $TinderboxDS );
		$this->moduleBuilds = $moduleBuilds;
		$this->moduleUsers  = $moduleUsers;
	}

	function checkQueueEntryAccess( $entry, $mode ) {

		if( $this->moduleUsers->checkWwwAdmin() ) {
			return true;
		}

		switch ( $mode ) {
			case 'list':		return true;
						break;
			case 'add':		if(  $this->moduleUsers->checkPermAddQueue( 'builds', $this->build_id ) ) {
							return true;
						} else {
							return false;
						}
						break;
			case 'modify':		if( $entry->getUserId() == $this->moduleUsers->get_id() &&
								$this->moduleUsers->checkPermModifyOwnQueue( 'builds', $this->build_id ) ) {
							return true;
						} elseif( $entry->getUserId() != $this->moduleUsers->get_id() &&
								  $this->moduleUsers->checkPermModifyOtherQueue( 'builds', $this->build_id ) ) {
							return true;
						} else {
							return false;
						}
						break;
			case 'delete':		if( $entry->getUserId() == $this->moduleUsers->get_id() &&
									$this->moduleUsers->checkPermDeleteOwnQueue( 'builds', $this->build_id ) ) {
							return true;
						} elseif( $entry->getUserId() != $this->moduleUsers->get_id() &&
								  $this->moduleUsers->checkPermDeleteOtherQueue( 'builds', $this->build_id ) ) {
							return true;
						} else {
							return false;
						}
						break;
			case 'priolower5':	if( $this->moduleUsers->checkPermPrioLower5( 'builds', $this->build_id ) ) {
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

	function list_tinderd_queue( $build_id ) {

			$all_builds = $this->moduleBuilds->get_all_builds();
			$allowed_builds = array();
			if( $this->moduleUsers->checkWwwAdmin() ) {
				$allowed_builds = $all_builds;
			} else {
				foreach( $all_builds as $build ) {
					if( $this->moduleUsers->checkPermAddQueue( 'builds', $build['build_id'] ) ) {
						$allowed_builds[] = $build;
					}
				}
			}
			$this->template_assign( 'all_builds', $all_builds );
			$this->template_assign( 'allowed_builds', $allowed_builds );
			$this->template_assign( 'build_id',   $build_id );
			$this->template_assign( 'new_build_id', '' );
			$this->template_assign( 'new_priority', '' );
			$this->template_assign( 'new_port_directory', '' );
			$this->template_assign( 'new_email_on_completion', '' );

			if( !empty( $build_id ) ) {
				$builds[0] = $this->TinderboxDS->getBuildById( $build_id );
				if ( ! $builds[0] ) {
					$this->TinderboxDS->addError( "Unknown build id: " . htmlentities( $build_id ) );
					$this->template_assign( 'no_list', true );
					return $this->template_parse( 'list_tinderd_queue.tpl' );
				}
			} else {
				$builds = $this->TinderboxDS->getAllBuilds();
			}

			$i = 0;
				foreach( $builds as $build ) {

					$this->build_id = $build->getId();

					if( is_object( $build ) ) {
						$build_ports_queue_entries = $this->TinderboxDS->getBuildPortsQueueEntries( $this->build_id );
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
														  'user'      => $build_ports_queue_entry->getUserName(),
														  'all_prio'  => $this->create_prio_array( $build_ports_queue_entry ),
														  'email_on_completion' => $build_ports_queue_entry->getEmailOnCompletion(),
														  'status_field_class'  => $status_field_class );

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

			if( !empty( $entries ) && is_array( $entries ) && count( $entries ) > 0 ) {
				$this->template_assign( 'entries', $entries );
				$this->template_assign( 'no_list', false );
			} else {
				$this->template_assign( 'no_list', true );
			}

			$this->template_assign( 'all_prio', array( 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ) );
			$this->template_assign( 'new_priority', 10 );
			$this->template_assign( 'is_logged_in' , $this->moduleUsers->is_logged_in() );

			return $this->template_parse( 'list_tinderd_queue.tpl' );
	}

	function change_tinderd_queue( $action, $entry_id, $build_id, $priority, $email_on_completion ) {

		if( !$this->moduleUsers->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		} else {
			$build_ports_queue_entry = $this->TinderboxDS->getBuildPortsQueueEntryById( $entry_id );
			if ( !empty ( $build_ports_queue_entry ) ) {
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
						$this->build_id = $build_id;
						if( $this->checkQueueEntryAccess( $build_ports_queue_entry, 'modify' ) ) {
							if( $build_ports_queue_entry->getPriority() != $priority && $priority < 5 && !$this->checkQueueEntryAccess( $build_ports_queue_entry, 'priolower5' ) ) {
								$this->TinderboxDS->addError( build_ports_queue_priority_to_low );
							} else {
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
		}
		return;
	}

	function add_tinderd_queue( $action, $build_id, $priority, $port_directories, $email_on_completion ) {

		if( !$this->moduleUsers->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		} else {
			if( empty( $build_id ) || empty( $priority ) || empty( $port_directories ) ) {
				$this->TinderboxDS->addError( mandatory_input_fields_are_empty );
			} else {
				$port_directories = explode( "\n", $port_directories );

				foreach( $port_directories as $port_directory ) {

					$port_directory = trim( $port_directory );

					if( empty( $port_directory ) ) {
						continue;
					}

					$build_ports_queue_entry = $this->TinderboxDS->createBuildPortsQueueEntry( $build_id, $priority, $port_directory, $this->moduleUsers->get_id(), $email_on_completion );
					if ( ! $build_ports_queue_entry ) {
						$this->TinderboxDS->addError( "Could not create ports queue entry." );
						return false;
					}
					$this->build_id = $build_id;
					if( $action == 'add' ) {
						if( $this->checkQueueEntryAccess( $build_ports_queue_entry, 'add' ) ) {
							if( $priority < 5 && !$this->checkQueueEntryAccess( $entry, 'priolower5' ) ) {
								$this->template_assign( 'new_build_id', $build_id );
								$this->template_assign( 'new_priority', $priority );
								$this->template_assign( 'new_port_directory', $port_directory );
								$this->template_assign( 'new_email_on_completion', $email_on_completion );
								$this->TinderboxDS->addError( build_ports_queue_priority_to_low );
							} else {
								$this->TinderboxDS->addBuildPortsQueueEntry( $build_ports_queue_entry );
							}
						} else {
							$this->template_assign( 'new_build_id', $build_id );
							$this->template_assign( 'new_priority', $priority );
							$this->template_assign( 'new_port_directory', $port_directory );
							$this->TinderboxDS->addError( build_ports_queue_not_allowed_to_add );
						}
					}
				}
			}
		}
		return;
	}

	function delete_tinderd_queue( $action, $build_id ) {

		if( !$this->moduleUsers->is_logged_in() ) {
			return $this->template_parse( 'please_login.tpl' );
		} else {
			if( !empty( $build_id ) ) {
				$builds[0] = $this->TinderboxDS->getBuildById( $build_id );
				if ( ! $builds[0] ) {
					$this->TinderboxDS->addError( "Unknown build id: " . htmlentities( $build_id ) );
					return false;
				}
			} else {
				$builds = $this->TinderboxDS->getAllBuilds();
			}
			foreach( $builds as $build ) {
				$this->build_id = $build->getId();
				if( is_object( $build ) ) {
					$build_ports_queue_entries = $this->TinderboxDS->getBuildPortsQueueEntries( $this->build_id );
					if( is_array( $build_ports_queue_entries ) && count( $build_ports_queue_entries ) > 0 ) {
						foreach( $build_ports_queue_entries as $build_ports_queue_entry ) {
							if( $this->checkQueueEntryAccess( $build_ports_queue_entry, 'delete' ) ) {
								if ( $action == 'delete all built' ) {
									if ( $build_ports_queue_entry->status != 'SUCCESS' ) {
										continue;
									}
								}
								$queue_id = $build_ports_queue_entry->getBuildPortsQueueId();
								$this->TinderboxDS->deleteBuildPortsQueueEntry( $queue_id );
							}
						}
					}
				}
			}
		}
		return;
	}
}
?>
