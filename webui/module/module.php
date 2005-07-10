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
# $MCom: portstools/tinderbox/webui/module/module.php,v 1.2 2005/07/10 07:39:18 oliver Exp $
#

require_once 'core/TinderboxDS.php';

class module {

	function module() {
		$this->TinderboxDS = new TinderboxDS();
	}
	
	function template_parse( $template ) {
		global $templatesdir;
		global $templatesuri;
		global $tinderbox_name;
		global $tinderbox_title;
		global $display_login;

		$this->template_assign( 'templatesuri',    $templatesuri    );
		$this->template_assign( 'tinderbox_name',  $tinderbox_name  );
		$this->template_assign( 'tinderbox_title', $tinderbox_title );
		$this->template_assign( 'display_login',   $display_login   );
		$this->template_assign( 'errors',          $this->TinderboxDS->getErrors() );

		foreach( $this->TEMPLATE_VARS as $varname => $varcontent ) {
			$varcontent = var_export( $varcontent, true );
			eval( '$'.$varname.' = '.$varcontent.';' );
		}
		ob_start();
		require $templatesdir.'/'.$template;
		$parsed = ob_get_contents();
		ob_end_clean();

		$this->template_cleanup();

		return $parsed;
	}
	
	function template_assign( $varname, $varcontent ) {
		$this->TEMPLATE_VARS[$varname] = $varcontent;
	}
	
	function template_cleanup() {
		return $this->TEMPLATE_VARS = array();
	}
}
?>
