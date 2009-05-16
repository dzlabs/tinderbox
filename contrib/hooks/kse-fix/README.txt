This Hook fixes the missing KSE kernel API problem when using Jails less
than 7.X on a -CURRENT build host.  This should be installed as a prePortBuild
Hook.  It makes use of a libmap.conf file found in ${pb}/patches.  That
libmap.conf file is included here.
