const std = @import("std");

const allocator = std.heap.page_allocator;

// all nodes created
pub var GlobalNodeList = std.ArrayList(*Node).init(allocator);

// all reachable nodes
pub var GlobalRootList = std.ArrayList(*Node).init(allocator);

pub const Node = struct {
    children: std.ArrayList(*Node),
    data: [512]u8 = undefined, // empty array initialization to 0
    visited: bool = false,

    pub fn init() !*Node {
        const n: *Node = try allocator.create(Node);
        try GlobalNodeList.append(n); // always keeping track of all nodes
        n.children = std.ArrayList(*Node).init(allocator);
        return n;
    }

    pub fn add_child(self: *Node, child: *Node) !void {
        try self.children.append(child);
    }
};

fn mark(node: *Node) !void {
    if (node.visited) {
        return;
    }
    node.visited = true;
    for (node.children.items) |child| {
        try mark(child);
    }
}

pub fn garbage_collect() !void {
    for (GlobalNodeList.items) |node| {
        node.visited = false;
    }

    for (GlobalRootList.items) |node| {
        try mark(node);
    }

    for (GlobalNodeList.items, 0..GlobalNodeList.items.len) |node, idx| {
        if (!node.visited) {
            allocator.destroy(node);
            _ = GlobalNodeList.orderedRemove(idx);
        }
    }
}

pub fn main() !void {}
