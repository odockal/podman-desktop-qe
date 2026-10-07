# Nodes section workflow

The [node topology and scheduling workflow](node-topology-scheduling.md)
validates the Nodes page with the three-node Kind prerequisite: inventory,
details, a reversible worker label, selector failure and recovery, and cleanup.

Use only the `test-node-workflow` namespace and remove the temporary label when
finished. Never delete, cordon, or drain Kind infrastructure nodes.
