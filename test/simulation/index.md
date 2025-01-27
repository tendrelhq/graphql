# Engine simulation tests

The simulation test suite is used to perform simulation testing against graphql
and the database. In particular, these tests attempt to inflict data corruption
through concurrency and (client) data staleness.

Concurrency means that multiple requests are in flight. Furthermore, concurrency
implies that some of these in flight requests may be conflicting, i.e. they are
modifying the same (or similar) sets of data. Internally, graphql and the sql
engine use optimistic concurrency control to mitigate these scenarios.

Data staleness means that a client request might not be applicable anymore
because sufficient time or, more likely, intermediate changes have rendered them
invalid, e.g. "starting" a task that was already "closed".

## How it works
