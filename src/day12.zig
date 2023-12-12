const std = @import("std");
const utils = @import("utils.zig");

fn fits_at(springs: []u8, start: usize, run_size: usize) bool {
    if (springs.len <= start + run_size) {
        return false;
    }
    for (start..start + run_size) |i| {
        if (springs[i] == '.') {
            return false;
        }
    }
    return start + run_size == springs.len or springs[start + run_size] != '#';
}

fn find_first_fit(springs: []u8, start_at: usize, run_len: usize) ?usize {
    // std.debug.print("finding in {s} from {d} len {d}\n", .{ springs, start_at, run_len });
    var i = start_at;
    while (i < springs.len and springs[i] == '.') : (i += 1) {}
    if (i == springs.len) {
        return null;
    }
    const run_start = i;
    while (i < springs.len) : (i += 1) {
        if (i - run_start == run_len) {
            if (springs[i] == '.' or springs[i] == '?') {
                return run_start;
            } else {
                return find_first_fit(springs, run_start + 1, run_len);
            }
        }
        if (springs[i] == '.') {
            return find_first_fit(springs, i, run_len);
        }
    }
    return null;
}

pub fn part1(file: *std.fs.File) !i32 {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    var ways = std.ArrayList(usize).init(alloc.allocator());
    defer ways.deinit();
    var new_ways = std.ArrayList(usize).init(alloc.allocator());
    defer new_ways.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const space_idx = utils.find(line, ' ').?;
        line[space_idx] = '.';
        const springs = line[0 .. space_idx + 1];
        try ways.append(1);
        try ways.appendNTimes(0, springs.len);
        var num_iter = utils.SplitNums(usize){ .line = line };
        // std.debug.print("{s} starts with {any}\n", .{ springs, ways.items });
        while (try num_iter.next()) |next| {
            try new_ways.appendNTimes(0, next + 1);
            var sum_since_last_broken: usize = 0;
            for (0..springs.len - next) |i| {
                sum_since_last_broken += ways.items[i];
                // std.debug.print("{d} {d} {any} \n", .{ i, sum_since_last_broken, new_ways.items });
                if (fits_at(springs, i, next)) {
                    // std.debug.print("{d} fits at {d} in {s}\n", .{ next, i, springs });
                    try new_ways.append(sum_since_last_broken);
                } else {
                    try new_ways.append(0);
                }
                if (springs[i] == '#') {
                    sum_since_last_broken = 0;
                }
            }
            // std.debug.print("{s} {d} {any}\n", .{ springs, next, new_ways.items });
            std.mem.swap(std.ArrayList(usize), &ways, &new_ways);
            new_ways.clearRetainingCapacity();
        }
        var linesum: usize = 0;
        for (ways.items[1..], springs) |way, spring| {
            linesum += way;
            if (spring == '#') {
                linesum = 0;
            }
        }
        sum += @intCast(linesum);
        // std.debug.print("{d} {s}\n", .{ linesum, line });
        ways.clearRetainingCapacity();
    }
    return sum;
}

pub fn part2(file: *std.fs.File) !isize {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    var sum: isize = 0;
    var nums = std.ArrayList(usize).init(alloc.allocator());
    defer nums.deinit();
    var ways = std.ArrayList(usize).init(alloc.allocator());
    defer ways.deinit();
    var new_ways = std.ArrayList(usize).init(alloc.allocator());
    defer new_ways.deinit();
    var springs = std.ArrayList(u8).init(alloc.allocator());
    defer springs.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const space_idx = utils.find(line, ' ').?;
        // line[space_idx] = '.';
        try springs.appendSlice(line[0..space_idx]);
        try springs.append('?');
        try springs.appendSlice(line[0..space_idx]);
        try springs.append('?');
        try springs.appendSlice(line[0..space_idx]);
        try springs.append('?');
        try springs.appendSlice(line[0..space_idx]);
        try springs.append('?');
        try springs.appendSlice(line[0..space_idx]);
        try springs.append('.');
        try ways.append(1);
        try ways.appendNTimes(0, springs.items.len);
        var num_iter = utils.SplitNums(usize){ .line = line };
        // std.debug.print("{s} starts with {any}\n", .{ springs.items, ways.items });
        while (try num_iter.next()) |next| {
            try nums.append(next);
        }
        for (0..5) |_| {
            for (nums.items) |next| {
                try new_ways.appendNTimes(0, next + 1);
                var sum_since_last_broken: usize = 0;
                for (0..springs.items.len - next) |i| {
                    sum_since_last_broken += ways.items[i];
                    // std.debug.print("{d} {d} {any} \n", .{ i, sum_since_last_broken, new_ways.items });
                    if (fits_at(springs.items, i, next)) {
                        // std.debug.print("{d} fits at {d} in {s}\n", .{ next, i, springs.items });
                        try new_ways.append(sum_since_last_broken);
                    } else {
                        try new_ways.append(0);
                    }
                    if (springs.items[i] == '#') {
                        sum_since_last_broken = 0;
                    }
                }
                // std.debug.print("{s} {d} {any}\n", .{ springs.items, next, new_ways.items });
                std.mem.swap(std.ArrayList(usize), &ways, &new_ways);
                new_ways.clearRetainingCapacity();
            }
        }
        var linesum: usize = 0;
        for (ways.items[1..], springs.items) |way, spring| {
            linesum += way;
            if (spring == '#') {
                linesum = 0;
            }
        }
        sum += @intCast(linesum);
        // std.debug.print("{d}\n", .{linesum});
        ways.clearRetainingCapacity();
        nums.clearRetainingCapacity();
        springs.clearRetainingCapacity();
    }
    return sum;
}
