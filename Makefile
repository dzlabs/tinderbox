# $MCom: portstools/tinderbox/Makefile,v 1.28 2005/09/05 04:47:08 marcus Exp $

VERSION=	2.0.0

DATA=		README buildscript create ds.ph.dist makemake \
		mkbuild mkjail pnohang.c portbuild rawenv.dist tc \
		tinderbox.ph.dist tinderbox-mysql.schema  \
		tinderbox-pgsql.schema tinderbuild tinderd upgrade.sh \
		setup.sh
LIBDATA=	Build.pm BuildPortsQueue.pm Host.pm Jail.pm MakeCache.pm \
		Port.pm PortsTree.pm TBConfig.pm TinderObject.pm \
		TinderboxDS.pm User.pm tinderlib.pl tinderbox_shlib.sh \
		setup_shlib.sh setup-mysql.sh setup-pgsql.sh
ETCRCDATA=	tinderd.sh
MIGDATA=	mig_shlib.sh mig_mysql_tinderbox-1.X_to_2.0.0.sql \
		mig_mysql_tinderbox-2.0.0_to_2.1.0.sql \
		mig_mysql_tinderbox-2.1.0_to_2.1.1.sql
MAN1DATA=	tc-configCcache.1 tc-configDistfile.1 tc-configGet.1 \
		tc-configJail.1 tc-configTinderd.1 tc-init.1
WWWDATA=	Build.php Jail.php Port.php PortsTree.php TinderObject.php \
		TinderboxDS.php inc_ds.php failures.php index.php \
		lastbuilds.php showbuild.php showport.php inc_tinderbox.php \
		tinderstyle.css Makefile
WWWEXPDATA=	inc_ds.php inc_tinderbox.php index.php
WWWEXPCDATA=	Build.php BuildPortsQueue.php Host.php Jail.php Port.php \
		PortsTree.php TinderObject.php TinderboxDS.php User.php
WWWEXPMDATA=	module.php moduleBuildPorts.php moduleBuilds.php \
		moduleHosts.php modulePorts.php moduleSession.php \
		moduleTinderd.php moduleUsers.php
WWWEXPTDATA=	current_buildports.tpl describe_port.tpl display_login.tpl \
		failed_buildports.tpl latest_buildports.tpl list_buildports.tpl \
		list_builds.tpl list_tinderd_queue.tpl messages.inc \
		please_login.tpl tinderstyle.css user_admin.tpl \
		user_permissions.tpl user_properties.tpl

release:
	-rm -rf ${.CURDIR}/tinderbox-${VERSION} \
		${.CURDIR}/tinderbox-${VERSION}.tar.gz
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}
.for f in ${DATA}
	cp ${f} ${.CURDIR}/tinderbox-${VERSION}
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/www
.for wf in ${WWWDATA}
	cp ${.CURDIR}/www/${wf} ${.CURDIR}/tinderbox-${VERSION}/www
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/www-exp
.for wef in ${WWWEXPDATA}
	cp ${.CURDIR}/www-exp/${wef} ${.CURDIR}/tinderbox-${VERSION}/www-exp
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/www-exp/core
.for wecf in ${WWWEXPCDATA}
	cp ${.CURDIR}/www-exp/core/${wecf} ${.CURDIR}/tinderbox-${VERSION}/www-exp/core
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/www-exp/module
.for wemf in ${WWWEXPMDATA}
	cp ${.CURDIR}/www-exp/module/${wemf} ${.CURDIR}/tinderbox-${VERSION}/www-exp/module
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/www-exp/templates/default
.for wetf in ${WWWEXPTDATA}
	cp ${.CURDIR}/www-exp/templates/default/${wetf} ${.CURDIR}/tinderbox-${VERSION}/www-exp/templates/default
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
