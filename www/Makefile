SRCS=	Port.php Build.php PortsTree.php TinderObject.php TinderboxDS.php \
	build.php index.php tinderstyle.css
DESTDIR?=	/www/data/tinderbox

install:
.for f in ${SRCS}
	cp ${f} ${DESTDIR}
.endfor
