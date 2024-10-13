const std = @import("std");
const main = @import("main.zig");

const allocator = std.testing.allocator;

test "garbage collector should deallocate unreachable nodes" {
    // Initialize memory manager
    const mgr = try main.MemoryManager.init();
    // Initialize root node
    var root = try main.Node.init(mgr);

    // Initialize child node and add to root
    const child = try main.Node.init(mgr);
    try root.add_child(child);

    // Initialize another node that is not connected to the root
    const orphan = try main.Node.init(mgr);

    // Perform garbage collection
    try mgr.garbage_collect();

    // Check that the orphan node has been deallocated
    var orphan_found = false;
    var it = mgr.nodeSet.keyIterator();
    while (it.next()) |node| {
        if (node.* == orphan) {
            orphan_found = true;
            break;
        }
    }

    try std.testing.expect(!orphan_found);
}
