SRCS=	Port.php Build.php PortsTree.php TinderObject.php TinderboxDS.php \
	index.php
DESTDIR?=	/www/data/tinderbox

install:
.for f in ${SRCS}
	cp ${f} ${DESTDIR}
.endfor
