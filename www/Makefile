SRCS=	Port.php Build.php Jail.php Port.php PortsTree.php TinderObject.php TinderboxDS.php \
	index.php failures.php lastbuilds.php showbuild.php showport.php tinderstyle.css
DESTDIR?=	/www/data/tinderbox

install:
.for f in ${SRCS}
	rm -f ${DESTDIR}/${f}
	cp ${f} ${DESTDIR}
.endfor
