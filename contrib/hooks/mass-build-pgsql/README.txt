One tinderbox issue is that ports are not picked from the queue in
a optimized order, so it can happen port-Z is the first in the queue
and needs to build first port-K port-R port-F ...

Without this small hack the full jail will be extracted also for
ports build as dependency for port-Z.

Now this small hook saves me sometimes a lot of time since it set
the state of this ports to SUCCESS/FAIL as soon they where build.

You will not see any great benefit with a small numbers of ports,
but for example during an expr-run with a view hundreds.

Hook is written for PGSQL, maybe it will also work with MySQL ...

If PGSQL needs authentication use ~/.pgpass !

Maybe this can be implemented directly in the code.

-- Olli Hauer
