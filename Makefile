# $MCom: portstools/tinderbox/Makefile,v 1.69 2009/05/23 18:53:26 marcus Exp $

VERSION=	3.0.0

DATA=		README ds.ph.dist tc tinderbox.ph.dist tinderd
LIBDATA=	buildscript db-mysql.sh db-pgsql.sh enterbuild makemake \
		pnohang.c portbuild tc_command.pl tc_command.sh \
		tinderlib.pl tinderlib.sh tinderbox.env
SQLDATA=	genschema schema.mysql.post schema.mysql.pre \
		schema.pgsql.post schema.pgsql.pre values.lp values.config \
		values.hooks values.pfp values.pfr
PERLMODDATA=	Build.pm BuildPortsQueue.pm Config.pm Hook.pm Jail.pm \
		MakeCache.pm Port.pm PortFailPattern.pm PortFailReason.pm \
		PortsTree.pm TinderObject.pm TinderboxDS.pm User.pm
ETCRCDATA=	tinderd
ENVDATA=	.keep_me
MIGDATA=	build_ports.map build_ports_queue.map builds.map config.map \
		hooks.map jails.map order.lst user_permissions.map
MAN1DATA=	tc-configCcache.1 tc-configDistfile.1 tc-configGet.1 \
		tc-configJail.1 tc-configTinderd.1 tc-init.1
WEBUIDATA=	favicon.ico inc_ds.php.dist inc_tinderbox.php.dist index.php
WEBUICDATA=	Build.php BuildPortsQueue.php Config.php Jail.php \
		LogfilePattern.php Port.php PortFailPattern.php \
		PortFailReason.php PortsTree.php TinderObject.php TinderboxDS.php \
		User.php functions.php
WEBUIMDATA=	module.php moduleBuildPorts.php moduleBuilds.php \
		moduleConfig.php moduleLogs.php modulePortFailureReasons.php \
		modulePorts.php moduleRss.php moduleSession.php \
		moduleTinderd.php moduleUsers.php
WEBUITDDATA=	config.tpl current_buildports.tpl describe_port.tpl \
		display_login.tpl display_markup_log.tpl failed_buildports.tpl \
		latest_buildports.tpl list_buildports.tpl list_builds.tpl \
		list_failure_reasons.tpl list_tinderd_queue.tpl messages.inc \
		please_login.tpl rss.tpl tinderstyle.css tinderstyle.js \
		user_admin.tpl user_permissions.tpl user_properties.tpl
WEBUITpaefchenDATA=config.tpl current_buildports.tpl describe_port.tpl \
		  display_login.tpl display_markup_log.tpl failed_buildports.tpl \
		  footer.inc.tpl header.inc.tpl latest_buildports.tpl \
		  list_buildports.tpl list_builds.tpl list_failure_reasons.tpl \
		  list_tinderd_queue.tpl messages.inc please_login.tpl \
		  rss.tpl tinderstyle.css tinderstyle.js user_admin.tpl \
		  user_permissions.tpl user_properties.tpl
WEBUITpaefchenIMAGEDATA=hdr_fill.png

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
.for wetf in ${WEBUITDDATA}
	cp ${.CURDIR}/webui/templates/default/${wetf} ${.CURDIR}/tinderbox-${VERSION}/webui/templates/default
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/webui/templates/paefchen
.for wetf in ${WEBUITpaefchenDATA}
	cp ${.CURDIR}/webui/templates/paefchen/${wetf} ${.CURDIR}/tinderbox-${VERSION}/webui/templates/paefchen
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/webui/templates/paefchen/images
.for wetif in ${WEBUITpaefchenIMAGEDATA}
	cp ${.CURDIR}/webui/templates/paefchen/images/${wetif} ${.CURDIR}/tinderbox-${VERSION}/webui/templates/paefchen/images
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/lib
.for lf in ${LIBDATA}
	cp ${.CURDIR}/lib/${lf} ${.CURDIR}/tinderbox-${VERSION}/lib
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/sql
.for sf in ${SQLDATA}
	cp ${.CURDIR}/sql/${sf} ${.CURDIR}/tinderbox-${VERSION}/sql
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/lib/Tinderbox
.for pmf in ${PERLMODDATA}
	cp ${.CURDIR}/lib/Tinderbox/${pmf} ${.CURDIR}/tinderbox-${VERSION}/lib/Tinderbox
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/etc/rc.d
.for erf in ${ETCRCDATA}
	cp ${.CURDIR}/etc/rc.d/${erf} ${.CURDIR}/tinderbox-${VERSION}/etc/rc.d
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/etc/env
.for eef in ${ENVDATA}
	cp ${.CURDIR}/etc/env/${eef} ${.CURDIR}/tinderbox-${VERSION}/etc/env
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/upgrade
.for mf in ${MIGDATA}
	cp ${.CURDIR}/upgrade/${mf} ${.CURDIR}/tinderbox-${VERSION}/upgrade
.endfor
.for ms in 1
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/man/man${ms}
.for mf in ${MAN${ms}DATA}
	cp ${.CURDIR}/man/man${ms}/${mf} ${.CURDIR}/tinderbox-${VERSION}/man/man${ms}
.endfor
.endfor
mkdir -p ${.CURDIR}/tinderbox-${VERSION}/contrib
tar -C ${.CURDIR}/contrib --exclude "*CVS*" -cf - . | \
    tar -C ${.CURDIR}/tinderbox-${VERSION}/contrib -xf -
	echo "Tinderbox version ${VERSION}" > tinderbox-${VERSION}/.version
	cd ${.CURDIR} && \
		tar cvzf tinderbox-${VERSION}.tar.gz tinderbox-${VERSION}
