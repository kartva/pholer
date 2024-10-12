const std = @import("std");
const main = @import("main.zig");

const allocator = std.testing.allocator;

test "garbage collector should deallocate unreachable nodes" {
    // Initialize root node
    var root = try main.Node.init();
    try main.GlobalRootList.append(root);

    // Initialize child node and add to root
    const child = try main.Node.init();
    try root.add_child(child);

    // Initialize another node that is not connected to the root
    const orphan = try main.Node.init();

    // Perform garbage collection
    try main.garbage_collect();

    // Check that the orphan node has been deallocated
    var orphan_found = false;
    for (main.GlobalNodeList.items) |node| {
        if (node == orphan) {
            orphan_found = true;
            break;
        }
    }
    try std.testing.expect(!orphan_found);

    // Clean up
    main.GlobalRootList.deinit();
    main.GlobalNodeList.deinit();
}
