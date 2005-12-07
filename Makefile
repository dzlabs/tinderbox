# $MCom: portstools/tinderbox/Makefile,v 1.36 2005/12/07 17:52:06 ade Exp $

VERSION=	3.0.0

DATA=		README ds.ph.dist tc tinderbox.ph.dist tinderd \
		tinderbox-mysql.schema tinderbox-pgsql.schema
LIBDATA=	Build.pm Host.pm Jail.pm MakeCache.pm \
		Port.pm PortsTree.pm TBConfig.pm TinderObject.pm \
		TinderboxDS.pm User.pm \
		buildscript enterbuild makemake pnohang.c portbuild
		setup-mysql.sh setup-pgsql.sh \
		tc_commands.pl tc_commands.sh tinderlib.pl tinderlib.sh \
		tinderbox.env
ETCRCDATA=
MIGDATA=
MAN1DATA=	tc-configCcache.1 tc-configDistfile.1 tc-configGet.1 \
		tc-configJail.1 tc-configTinderd.1 tc-init.1
WEBUIDATA=	inc_ds.php inc_tinderbox.php index.php
WEBUICDATA=	Build.php Host.php Jail.php Port.php \
		PortsTree.php TinderObject.php TinderboxDS.php User.php
WEBUIMDATA=	module.php moduleBuildPorts.php moduleBuilds.php \
		moduleHosts.php modulePorts.php moduleSession.php \
		moduleUsers.php
WEBUITDATA=	current_buildports.tpl describe_port.tpl display_login.tpl \
		failed_buildports.tpl latest_buildports.tpl list_buildports.tpl \
		list_builds.tpl messages.inc \
		please_login.tpl tinderstyle.css user_admin.tpl \
		user_properties.tpl

release:
	-rm -rf ${.CURDIR}/tinderbox-${VERSION} \
		${.CURDIR}/tinderbox-${VERSION}.tar.gz
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}
.for f in ${DATA}
	cp ${f} ${.CURDIR}/tinderbox-${VERSION}
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/webui
.for wef in ${WEBUIDATA}
	cp ${.CURDIR}/webui/${wef} ${.CURDIR}/tinderbox-${VERSION}/webui
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/webui/core
.for wecf in ${WEBUICDATA}
	cp ${.CURDIR}/webui/core/${wecf} ${.CURDIR}/tinderbox-${VERSION}/webui/core
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/webui/module
.for wemf in ${WEBUIMDATA}
	cp ${.CURDIR}/webui/module/${wemf} ${.CURDIR}/tinderbox-${VERSION}/webui/module
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/webui/templates/default
.for wetf in ${WEBUITDATA}
	cp ${.CURDIR}/webui/templates/default/${wetf} ${.CURDIR}/tinderbox-${VERSION}/webui/templates/default
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/lib
.for lf in ${LIBDATA}
	cp ${.CURDIR}/lib/${lf} ${.CURDIR}/tinderbox-${VERSION}/lib
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/upgrade
.for erf in ${ETCRCDATA}
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/etc/rc.d
	cp ${.CURDIR}/etc/rc.d/${erf} ${.CURDIR}/tinderbox-${VERSION}/etc/rc.d
.endfor
.for mf in ${MIGDATA}
	cp ${.CURDIR}/upgrade/${mf} ${.CURDIR}/tinderbox-${VERSION}/upgrade
.endfor
.for ms in 1
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/man/man${ms}
.for mf in ${MAN${ms}DATA}
	cp ${.CURDIR}/man/man${ms}/${mf} ${.CURDIR}/tinderbox-${VERSION}/man/man${ms}
.endfor
.endfor
	cd ${.CURDIR} && \
		tar cvzf tinderbox-${VERSION}.tar.gz tinderbox-${VERSION}
