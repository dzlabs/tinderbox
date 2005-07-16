# $MCom: portstools/tinderbox/Makefile,v 1.13 2005/07/16 07:47:35 marcus Exp $

VERSION=	2.0.0

DATA=		Build.pm BuildPortsQueue.pm Host.pm Jail.pm Port.pm \
		PortsTree.pm README TinderObject.pm TinderboxDS.pm User.pm \
		buildenv buildscript create_new_build create_new_jail \
		create_new_portstree ds.ph list_jails makemake \
		mkbuild mkjail pnohang.c portbuild rawenv tc tinderbox.ph \
		tinderbox.schema tinderbuild tinderd tinderlib.pl \
		tinderbox_shlib.sh
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
	cd ${.CURDIR} && \
		tar cvzf tinderbox-${VERSION}.tar.gz tinderbox-${VERSION}
