const std = @import("std");
const utils = @import("utils.zig");

const Location = [3]u8;
const Pair = struct {
    left: Location,
    right: Location,
};

const LocationContext = struct {
    const Self = @This();
    fn hash(_: *Self, loc: Location) u64 {
        return loc[0] << 16 + loc[1] << 8 + loc[2];
    }

    fn eql(_: *Self, a: Location, b: Location) bool {
        return a[0] == b[0] and a[1] == b[1] and a[2] == b[2];
    }
};

pub fn part1(file: *std.fs.File) !i32 {
    var buf: [20]u8 = undefined;
    const reader = file.reader();

    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var locations = std.AutoArrayHashMap(Location, Pair).init(alloc.allocator());
    defer locations.deinit();
    var directions_buf: [300]u8 = undefined;
    const directions_line = (try reader.readUntilDelimiterOrEof(&directions_buf, '\n')).?;
    const directions = directions_line[0 .. directions_line.len - 1];
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const location: [3]u8 = line[0..3].*;
        const left: [3]u8 = line[7..10].*;
        const right: [3]u8 = line[12..15].*;
        try locations.put(location, Pair{ .left = left, .right = right });
    }

    var curr_location: [3]u8 = .{ 'A', 'A', 'A' };
    var steps: usize = 0;
    var loc_cxt = LocationContext{};
    while (!loc_cxt.eql(curr_location, .{ 'Z', 'Z', 'Z' })) {
        const dir = directions[steps % directions.len];
        steps += 1;
        const this_loc = locations.get(curr_location).?;
        if (dir == 'L') {
            curr_location = this_loc.left;
        } else {
            curr_location = this_loc.right;
        }
    }

    return @intCast(steps);
}

const Path = struct {
    zs: std.ArrayList(u16),
    end: Location,
};

pub fn part2(file: *std.fs.File) !i32 {
    var buf: [20]u8 = undefined;
    const reader = file.reader();

    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var locations = std.AutoArrayHashMap(Location, Pair).init(alloc.allocator());
    defer locations.deinit();
    var directions_buf: [300]u8 = undefined;
    const directions_line = (try reader.readUntilDelimiterOrEof(&directions_buf, '\n')).?;
    const directions = directions_line[0 .. directions_line.len - 1];
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
    var current_locations = std.ArrayList(Location).init(alloc.allocator());
    defer current_locations.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const location: [3]u8 = line[0..3].*;
        const left: [3]u8 = line[7..10].*;
        const right: [3]u8 = line[12..15].*;
        try locations.put(location, Pair{ .left = left, .right = right });
        if (location[2] == 'A') {
            try current_locations.append(location);
        }
    }

    std.debug.print("{any}\n", .{current_locations.items});
    var caches = std.AutoArrayHashMap(Location, Path).init(alloc.allocator());
    defer caches.deinit();
    var iter = locations.iterator();
    while (iter.next()) |loc| {
        var curr = loc.key_ptr.*;
        var steps: u16 = 0;
        var zs = std.ArrayList(u16).init(alloc.allocator());
        for (directions) |dir| {
            const this_loc = locations.get(curr).?;
            if (dir == 'L') {
                curr = this_loc.left;
            } else {
                curr = this_loc.right;
            }
            if (curr[2] == 'Z') {
                try zs.append(steps);
            }
            steps += 1;
        }
        try caches.put(loc.key_ptr.*, Path{ .zs = zs, .end = curr });
    }

    var cache_iter_2 = caches.iterator();
    while (cache_iter_2.next()) |cache| {
        std.debug.print("{any}, {any}/{any}\n", .{ cache.key_ptr.*, cache.value_ptr.*.end, cache.value_ptr.*.zs.items });
    }
    var steps: usize = 0;
    std.debug.print("{any}\n", .{current_locations.items});
    const step_count: u16 = outer: while (true) : (steps += 1) {
        const first = current_locations.items[0];
        step_iter: for (caches.get(first).?.zs.items) |step| {
            location: for (current_locations.items[1..]) |loc| {
                if (caches.get(loc).?.zs.items.len == 0) {
                    break :step_iter;
                }
                for (caches.get(loc).?.zs.items) |z| {
                    if (z == step) {
                        continue :location;
                    }
                }
                continue :step_iter;
            }
            break :outer step;
        }
        for (current_locations.items) |*loc| {
            loc.* = caches.get(loc.*).?.end;
        }
        if (steps % 10000000 == 0) {
            std.debug.print("{d}\n", .{steps});
        }
    };

    var cache_iter = caches.iterator();
    while (cache_iter.next()) |cache| {
        cache.value_ptr.zs.deinit();
    }

    const step_count_u: usize = @intCast(step_count);
    const total_step_count = steps * directions.len + step_count_u + 1;
    std.debug.print("{d}*{d} + {d}\n", .{ steps, directions.len, step_count_u + 1 });
    std.debug.print("{d}\n", .{total_step_count});
    return 0;

    // var steps: usize = 0;
    // var all_z = false;
    // std.debug.print("{any}\n", .{current_locations.items});
    // while (!all_z) {
    //     const dir = directions[steps % directions.len];
    //     steps += 1;
    //     all_z = true;
    //     for (current_locations.items) |*loc| {
    //         const this_loc = locations.get(loc.*).?;
    //         if (dir == 'L') {
    //             loc.* = this_loc.left;
    //         } else {
    //             loc.* = this_loc.right;
    //         }
    //         if (loc[2] != 'Z') {
    //             all_z = false;
    //         }
    //     }
    //     if (steps % 10000000 == 0) {
    //         std.debug.print("{d}\n", .{steps});
    //     }
    // }
}
