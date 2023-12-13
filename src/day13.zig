const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(file: *std.fs.File) !i32 {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    var rows = std.ArrayList(std.ArrayList(u8)).init(alloc.allocator());
    defer rows.deinit();
    var cols = std.ArrayList(std.ArrayList(u8)).init(alloc.allocator());
    defer cols.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len > 3) {
            if (cols.items.len == 0) {
                for (0..line.len - 1) |_| {
                    try cols.append(std.ArrayList(u8).init(alloc.allocator()));
                }
            }
            var new_row = std.ArrayList(u8).init(alloc.allocator());
            try new_row.appendSlice(line[0 .. line.len - 1]);
            try rows.append(new_row);
            for (0..line.len - 1) |n| {
                try cols.items[n].append(line[n]);
            }
            continue;
        }
        // for (rows.items) |r| {
        //     std.debug.print("{s}\n", .{r.items});
        // }
        // for (cols.items) |c| {
        //     std.debug.print("{s}\n", .{c.items});
        // }
        find_reflect: {
            for (1..cols.items.len) |c| {
                // std.debug.print("Checking reflect about col {d}\n", .{c});
                for (0..c) |i| {
                    const reflect = c - i + c - 1;
                    // std.debug.print("Checking cols {d} vs {d}\n", .{ i, reflect });
                    if (cols.items.len <= reflect) {
                        continue;
                    }
                    if (reflect < 0) {
                        sum += @intCast(c);
                        // std.debug.print("Found reflect about col {d}\n", .{c});
                        break :find_reflect;
                    }
                    if (!std.mem.eql(u8, cols.items[i].items, cols.items[reflect].items)) {
                        break;
                    }
                } else {
                    sum += @intCast(c);
                    // std.debug.print("Found reflect about col {d}\n", .{c});
                    break :find_reflect;
                }
            }
            for (1..rows.items.len) |r| {
                // std.debug.print("Checking reflect about row {d}\n", .{r});
                for (0..r) |i| {
                    const reflect = r - i + r - 1;
                    // std.debug.print("Checking rows {d} vs {d}\n", .{ i, reflect });
                    if (rows.items.len <= reflect) {
                        continue;
                    }
                    if (reflect < 0) {
                        sum += @intCast(100 * r);
                        // std.debug.print("Found reflect about row {d}\n", .{r});
                        break :find_reflect;
                    }
                    if (!std.mem.eql(u8, rows.items[i].items, rows.items[reflect].items)) {
                        break;
                    }
                } else {
                    sum += @intCast(100 * r);
                    // std.debug.print("Found reflect about row {d}\n", .{r});
                    break :find_reflect;
                }
            }
        }
        for (cols.items) |col| {
            col.deinit();
        }
        for (rows.items) |row| {
            row.deinit();
        }
        cols.clearRetainingCapacity();
        rows.clearRetainingCapacity();
    }
    return sum;
}

fn count_defects(a: []const u8, b: []const u8) usize {
    var defects: usize = 0;
    for (a, b) |ac, bc| {
        if (ac != bc) {
            defects += 1;
        }
    }
    return defects;
}

pub fn part2(file: *std.fs.File) !i32 {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    var rows = std.ArrayList(std.ArrayList(u8)).init(alloc.allocator());
    defer rows.deinit();
    var cols = std.ArrayList(std.ArrayList(u8)).init(alloc.allocator());
    defer cols.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len > 3) {
            if (cols.items.len == 0) {
                for (0..line.len - 1) |_| {
                    try cols.append(std.ArrayList(u8).init(alloc.allocator()));
                }
            }
            var new_row = std.ArrayList(u8).init(alloc.allocator());
            try new_row.appendSlice(line[0 .. line.len - 1]);
            try rows.append(new_row);
            for (0..line.len - 1) |n| {
                try cols.items[n].append(line[n]);
            }
            continue;
        }
        // for (rows.items) |r| {
        //     std.debug.print("{s}\n", .{r.items});
        // }
        // for (cols.items) |c| {
        //     std.debug.print("{s}\n", .{c.items});
        // }
        find_reflect: {
            for (1..cols.items.len) |c| {
                // std.debug.print("Checking reflect about col {d}\n", .{c});
                var defects: usize = 0;
                for (0..c) |i| {
                    const reflect = c - i + c - 1;
                    // std.debug.print("Checking cols {d} vs {d}\n", .{ i, reflect });
                    if (cols.items.len <= reflect) {
                        continue;
                    }
                    if (reflect < 0) {
                        if (defects == 1) {
                            sum += @intCast(c);
                            // std.debug.print("Found reflect about col {d}\n", .{c});
                            break :find_reflect;
                        } else {
                            break;
                        }
                    }
                    defects += count_defects(cols.items[i].items, cols.items[reflect].items);
                    // std.debug.print("{d} defects\n", .{defects});
                    if (defects > 1) {
                        // std.debug.print("!!!{d} defects found\n", .{defects});
                        break;
                    }
                } else if (defects == 1) {
                    sum += @intCast(c);
                    // std.debug.print("Found reflect about col {d}\n", .{c});
                    break :find_reflect;
                }
            }
            for (1..rows.items.len) |r| {
                // std.debug.print("Checking reflect about row {d}\n", .{r});
                var defects: usize = 0;
                for (0..r) |i| {
                    const reflect = r - i + r - 1;
                    // std.debug.print("Checking rows {d} vs {d}\n", .{ i, reflect });
                    if (rows.items.len <= reflect) {
                        continue;
                    }
                    if (reflect < 0) {
                        if (defects == 1) {
                            sum += @intCast(100 * r);
                            // std.debug.print("Found reflect about row {d}\n", .{r});
                            break :find_reflect;
                        } else {
                            break;
                        }
                    }
                    defects += count_defects(rows.items[i].items, rows.items[reflect].items);
                    // std.debug.print("{d} defects found\n", .{defects});
                    if (defects > 1) {
                        // std.debug.print("!!!{d} defects found\n", .{defects});
                        break;
                    }
                } else if (defects == 1) {
                    sum += @intCast(100 * r);
                    // std.debug.print("Found reflect about row {d}\n", .{r});
                    break :find_reflect;
                }
            }
        }
        for (cols.items) |col| {
            col.deinit();
        }
        for (rows.items) |row| {
            row.deinit();
        }
        cols.clearRetainingCapacity();
        rows.clearRetainingCapacity();
    }
    return sum;
}
