# $MCom: portstools/tinderbox/Makefile,v 1.20 2005/07/21 06:34:51 ade Exp $

VERSION=	2.0.0

DATA=		README buildscript create ds.ph.dist makemake \
		mkbuild mkjail pnohang.c portbuild rawenv.dist tc \
		tinderbox.ph.dist tinderbox.schema tinderbuild tinderd \
		upgrade.sh setup.sh
LIBDATA=	Build.pm BuildPortsQueue.pm Host.pm Jail.pm MakeCache.pm \
		Port.pm PortsTree.pm TBConfig.pm TinderObject.pm \
		TinderboxDS.pm User.pm tinderlib.pl tinderbox_shlib.sh \
		setup_shlib.sh
MIGDATA=	mig_shlib.sh mig_tinderbox-1.X_to_2.0.0.sql
WWWDATA=	Build.php Jail.php Port.php PortsTree.php TinderObject.php \
		TinderboxDS.php cleanup.php inc_ds.php failures.php index.php \
		lastbuilds.php showbuild.php showport.php inc_tinderbox.php \
		tinderstyle.css Makefile

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
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/lib
.for lf in ${LIBDATA}
	cp ${.CURDIR}/lib/${lf} ${.CURDIR}/tinderbox-${VERSION}/lib
.endfor
	mkdir -p ${.CURDIR}/tinderbox-${VERSION}/upgrade
.for mf in ${MIGDATA}
	cp ${.CURDIR}/upgrade/${mf} ${.CURDIR}/tinderbox-${VERSION}/upgrade
.endfor
	cd ${.CURDIR} && \
		tar cvzf tinderbox-${VERSION}.tar.gz tinderbox-${VERSION}
