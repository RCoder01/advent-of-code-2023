const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(file: *std.fs.File) !i32 {
    var buf1: [50]u8 = undefined;
    var buf2: [50]u8 = undefined;
    const reader = file.reader();
    var prod: i32 = 1;

    const times_line = (try reader.readUntilDelimiterOrEof(&buf1, '\n')).?;
    const distances_line = (try reader.readUntilDelimiterOrEof(&buf2, '\n')).?;
    var times_iter = utils.SplitNums(i32){ .line = times_line };
    var distances_iter = utils.SplitNums(i32){ .line = distances_line };
    while (try times_iter.next()) |time| {
        const distance = (try distances_iter.next()).? + 1;
        // a+b = time, ab = distance; b = distance/a = time-a;
        // atime-a^2 = distance; -a^2 + atime - distance = 0;
        // a = (time +- sqrt(time^2 - 4distance))/2
        // b = time - a

        // time=7, distance=9: (7 +- sqrt(49-36))/2 = (7 +- sqrt(13))/2 = 5.30277564, 1.69722436
        // actual is 2, 5
        const sqrt: f32 = @floatFromInt(time * time - 4 * distance);
        const diff = @sqrt(sqrt);
        const ftime: f32 = @floatFromInt(time);
        const a = (ftime + diff) / 2;
        const b = (ftime - diff) / 2;
        const ia: i32 = @intFromFloat(@round(a - 0.5 + 1e-5));
        const ib: i32 = @intFromFloat(@round(b + 0.5 - 1e-5));
        const num_ways = (ia - ib) + 1;
        std.debug.print("{d}, {d}, {d}, {d}, {d}, {d}, {d}, {d}\n", .{ time, distance, num_ways, ia, ib, sqrt, a, b });
        prod *= num_ways;
    }
    return prod;
}

pub fn part2(file: *std.fs.File) !i32 {
    var buf1: [50]u8 = undefined;
    const reader = file.reader();

    var list = utils.BufferList(30, u8){};
    const times_line = (try reader.readUntilDelimiterOrEof(&buf1, '\n')).?;
    for (times_line) |ch| {
        if (std.ascii.isDigit(ch)) {
            try list.append(ch);
        }
    }
    const time = try std.fmt.parseInt(i64, list.data(), 10);
    list.len = 0;
    const dist_line = (try reader.readUntilDelimiterOrEof(&buf1, '\n')).?;
    for (dist_line) |ch| {
        if (std.ascii.isDigit(ch)) {
            try list.append(ch);
        }
    }
    const dist = try std.fmt.parseInt(i64, list.data(), 10);

    const sqrt: f64 = @floatFromInt(time * time - 4 * dist);
    const diff = @sqrt(sqrt);
    const ftime: f64 = @floatFromInt(time);
    const a = (ftime + diff) / 2;
    const b = (ftime - diff) / 2;
    const ia: i32 = @intFromFloat(@round(a - 0.5 + 1e-5));
    const ib: i32 = @intFromFloat(@round(b + 0.5 - 1e-5));
    const num_ways = (ia - ib) + 1;
    std.debug.print("{d}, {d}, {d}, {d}, {d}, {d}, {d}, {d}\n", .{ time, dist, num_ways, ia, ib, sqrt, a, b });
    return num_ways;
}
