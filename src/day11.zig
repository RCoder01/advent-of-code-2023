const std = @import("std");
const utils = @import("utils.zig");

const Pos = struct {
    x: usize,
    y: usize,
};

pub fn part1(file: *std.fs.File) !i32 {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var buf: [300]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    var empty_cols = std.ArrayList(bool).init(alloc.allocator());
    defer empty_cols.deinit();
    var empty_rows = std.ArrayList(bool).init(alloc.allocator());
    defer empty_rows.deinit();
    var galaxies = std.ArrayList(Pos).init(alloc.allocator());
    defer galaxies.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (empty_cols.items.len == 0) {
            try empty_cols.appendNTimes(true, line.len - 1);
        }
        try empty_rows.append(true);
        var remainder = line;
        while (utils.find(remainder, '#')) |pos| {
            const x = pos + line.len - remainder.len;
            const y = empty_rows.items.len - 1;
            empty_rows.items[y] = false;
            empty_cols.items[x] = false;
            try galaxies.append(Pos{
                .x = x,
                .y = y,
            });
            remainder = remainder[pos + 1 ..];
        }
    }
    // std.debug.print("{any}\n", .{galaxies.items});
    for (galaxies.items, 0..galaxies.items.len) |a, i| {
        for (galaxies.items[i + 1 ..], i + 1..galaxies.items.len) |b, j| {
            _ = j;

            const min_x = @min(a.x, b.x);
            const max_x = @max(a.x, b.x);
            const min_y = @min(a.y, b.y);
            const max_y = @max(a.y, b.y);
            var x_dist = max_x - min_x;
            var y_dist = max_y - min_y;
            for (min_x..max_x) |x| {
                if (empty_cols.items[x]) {
                    x_dist += 1;
                }
            }
            for (min_y..max_y) |y| {
                if (empty_rows.items[y]) {
                    y_dist += 1;
                }
            }
            // std.debug.print("Distance from {d} to {d}: {d}\n", .{ i + 1, j + 1, x_dist + y_dist });
            const pair_dist: i32 = @intCast(x_dist + y_dist);
            sum += pair_dist;
        }
    }
    return sum;
}

pub fn part2(file: *std.fs.File) !isize {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var buf: [300]u8 = undefined;
    const reader = file.reader();
    var sum: isize = 0;
    var empty_cols = std.ArrayList(bool).init(alloc.allocator());
    defer empty_cols.deinit();
    var empty_rows = std.ArrayList(bool).init(alloc.allocator());
    defer empty_rows.deinit();
    var galaxies = std.ArrayList(Pos).init(alloc.allocator());
    defer galaxies.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (empty_cols.items.len == 0) {
            try empty_cols.appendNTimes(true, line.len - 1);
        }
        try empty_rows.append(true);
        var remainder = line;
        while (utils.find(remainder, '#')) |pos| {
            const x = pos + line.len - remainder.len;
            const y = empty_rows.items.len - 1;
            empty_rows.items[y] = false;
            empty_cols.items[x] = false;
            try galaxies.append(Pos{
                .x = x,
                .y = y,
            });
            remainder = remainder[pos + 1 ..];
        }
    }
    // std.debug.print("{any}\n", .{galaxies.items});
    for (galaxies.items, 0..galaxies.items.len) |a, i| {
        for (galaxies.items[i + 1 ..], i + 1..galaxies.items.len) |b, j| {
            _ = j;

            const min_x = @min(a.x, b.x);
            const max_x = @max(a.x, b.x);
            const min_y = @min(a.y, b.y);
            const max_y = @max(a.y, b.y);
            var x_dist = max_x - min_x;
            var y_dist = max_y - min_y;
            for (min_x..max_x) |x| {
                if (empty_cols.items[x]) {
                    x_dist += 1000000 - 1;
                }
            }
            for (min_y..max_y) |y| {
                if (empty_rows.items[y]) {
                    y_dist += 1000000 - 1;
                }
            }
            // std.debug.print("Distance from {d} to {d}: {d}\n", .{ i + 1, j + 1, x_dist + y_dist });
            const pair_dist: isize = @intCast(x_dist + y_dist);
            sum += pair_dist;
        }
    }
    return sum;
}
