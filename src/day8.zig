const std = @import("std");
const utils = @import("utils.zig");

const Location = [3]u8;
const Pair = struct {
    left: Location,
    right: Location,
};

fn loc_eql(a: Location, b: Location) bool {
    return a[0] == b[0] and a[1] == b[1] and a[2] == b[2];
}

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
    while (!loc_eql(curr_location, .{ 'Z', 'Z', 'Z' })) {
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

const Cycle = struct {
    zs: std.ArrayList(usize),
    steps: usize,
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

    var initial_steps: usize = 0;
    var all_z = false;
    std.debug.print("{any}\n", .{current_locations.items});
    while (!all_z) {
        const dir = directions[initial_steps % directions.len];
        initial_steps += 1;
        all_z = true;
        for (current_locations.items) |*loc| {
            const this_loc = locations.get(loc.*).?;
            if (dir == 'L') {
                loc.* = this_loc.left;
            } else {
                loc.* = this_loc.right;
            }
            if (loc[2] != 'Z') {
                all_z = false;
            }
        }
        if (initial_steps == locations.count() * directions.len) {
            break;
        }
    }
    if (all_z) {
        std.debug.print("{d}\n", .{initial_steps});
        return 0;
    }

    std.debug.print("{d}\n", .{initial_steps});
    std.debug.print("{any}\n", .{current_locations.items});
    var loops = std.ArrayList(Cycle).init(alloc.allocator());
    for (current_locations.items) |item| {
        var zs = std.ArrayList(usize).init(alloc.allocator());
        var current = item;
        var steps: usize = 0;
        var cycles: usize = 0;
        while (!loc_eql(current, item) or cycles == 0) {
            for (directions) |dir| {
                const this_loc = locations.get(current).?;
                if (dir == 'L') {
                    current = this_loc.left;
                } else {
                    current = this_loc.right;
                }
                if (current[2] == 'Z') {
                    try zs.append(steps);
                }
                steps += 1;
            }
            cycles += 1;
        }
        std.debug.print("{s} {d} {any}\n", .{ item, cycles, zs.items });
        try loops.append(Cycle{ .zs = zs, .steps = steps });
    }

    var initial = loops.items[0];
    var temp_zs = std.ArrayList(usize).init(alloc.allocator());
    for (loops.items[1..]) |loop| {
        const combined_cycle: usize = (initial.steps / std.math.gcd(initial.steps, loop.steps)) * loop.steps;
        std.debug.print("{d} {any}\n", .{ combined_cycle, initial.zs.items });
        for (initial.zs.items) |item| {
            try temp_zs.append(item);
        }
        initial.zs.clearRetainingCapacity();
        while (temp_zs.items[0] < combined_cycle and loop.zs.items[0] < combined_cycle) {
            // std.debug.print("{any} {any}\n", .{ temp_zs.items, loop.zs.items });
            if (temp_zs.items[0] > loop.zs.items[loop.zs.items.len - 1]) {
                for (loop.zs.items) |*item| {
                    item.* += loop.steps;
                }
            } else if (loop.zs.items[0] > temp_zs.items[temp_zs.items.len - 1]) {
                for (temp_zs.items) |*item| {
                    item.* += initial.steps;
                }
            } else {
                for (temp_zs.items) |a| {
                    for (loop.zs.items) |b| {
                        if (a == b) {
                            try initial.zs.append(a);
                        }
                    }
                }
                for (temp_zs.items) |*item| {
                    item.* += initial.steps;
                }
                for (loop.zs.items) |*item| {
                    item.* += loop.steps;
                }
            }
        }
        loop.zs.deinit();
        temp_zs.clearRetainingCapacity();
        initial.steps = combined_cycle;
        std.debug.print("{d} {any}\n", .{ combined_cycle, initial.zs.items });
    }

    std.debug.print("{d}\n", .{initial.zs.items[0] + initial_steps});

    return 0;
}
