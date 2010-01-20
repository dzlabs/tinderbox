$MCom: portstools/tinderbox/contrib/hooks/compress_wrkdir/README.txt,v 1.1 2010/01/20 23:58:25 itetcu Exp $

 If installed as a postPortBuild Hook, it will compress the wrkdir. Since this
 is a time consuming job, by default it only compresses it for failed builds.
 If you want to compress all the wrkdirs un-comment COMPRESS_ALL in the script.

 If you don't change the path, tindy's WebUI will show a link to the tarball.

 Install it via
 ./tc updateHookCmd -h postPortBuild -c full_path/to/compress_wrkdir.sh
 Disable it via:
 ./tc updateHookCmd -h postPortBuild
 An other way to "disable" it is to put 'exit 0' as the first instruction in
 the script.
