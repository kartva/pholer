const std = @import("std");

const allocator = std.heap.page_allocator;

pub const MemoryManager: type = struct {
    clearList: std.ArrayList(*Node),
    nodeSet: std.AutoHashMap(*Node, void),
    rootSet: std.AutoHashMap(*Node, void),

    pub fn init() !*MemoryManager {
        const m: *MemoryManager = try allocator.create(MemoryManager);
        m.clearList = std.ArrayList(*Node).init(allocator);
        m.nodeSet = std.AutoHashMap(*Node, void).init(allocator);
        m.rootSet = std.AutoHashMap(*Node, void).init(allocator);
        return m;
    }

    pub fn addNode(self: *MemoryManager, node: *Node) !void {
        try self.rootSet.put(node, {});
        node.visited = false;
    }

    pub fn addRoot(self: *MemoryManager, node: *Node) !void {
        self.nodeSet.put(node);
        self.rootSet.put(node);
        node.visited = false;
    }

    pub fn garbage_collect(self: *MemoryManager) !void {
        // mark all nodes
        var it = self.rootSet.keyIterator();
        while (it.next()) |node| {
            try node.*.mark();
        }
        // sweep all nodes
        var it2 = self.nodeSet.keyIterator();
        while (it2.next()) |node| {
            if (!node.*.visited) {
                try self.clearList.append(node.*);
            }
            node.*.visited = false;
        }

        for (self.clearList.items) |node| {
            _ = self.nodeSet.remove(node);
            try node.cleanup();
        }

        // clear out the clearing list
        self.clearList.shrinkRetainingCapacity(0);
    }
};

pub const Node = struct {
    children: std.ArrayList(*Node),
    data: [512]u8 = undefined, // empty array initialization to 0
    visited: bool = false,

    pub fn init(mem: *MemoryManager) !*Node {
        const n: *Node = try allocator.create(Node);
        n.children = std.ArrayList(*Node).init(allocator);
        try mem.addNode(n);
        return n;
    }

    pub fn add_child(self: *Node, child: *Node) !void {
        try self.children.append(child);
    }

    fn mark(node: *Node) !void {
        if (node.visited) {
            return;
        }
        node.visited = true;
        for (node.children.items) |child| {
            try mark(child);
        }
    }

    fn cleanup(node: *Node) !void {
        node.visited = false;
    }
};
pub fn main() !void {}
