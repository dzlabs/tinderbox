SRCS=	Port.php Build.php PortsTree.php TinderObject.php TinderboxDS.php \
	index.php lastbuilds.php showbuild.php showport.php tinderstyle.css
DESTDIR?=	/www/data/tinderbox

install:
.for f in ${SRCS}
	rm -f ${DESTDIR}/${f}
	cp ${f} ${DESTDIR}
.endfor
