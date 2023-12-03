const std = @import("std");
const utils = @import("utils.zig");

const NumRange = struct {
    num: i32,
    min: i32,
    max: i32,
};

fn range_contains(min: i32, max: i32, list: []i32) bool {
    for (list) |val| {
        if (val < min) {
            continue;
        } else if (val < max) {
            return true;
        } else {
            return false;
        }
    }
    return false;
}

pub fn part1(file: *std.fs.File) !i32 {
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    const NumRangeBufList = utils.BufferList(32, NumRange);
    var prev_line = NumRangeBufList.new();
    var this_line = NumRangeBufList.new();
    const IntBufList = utils.BufferList(150, i32);
    var prev_line_symbols = IntBufList.new();
    var this_line_symbols = IntBufList.new();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var num_start: ?usize = null;
        for (line, 0..line.len) |ch, i| {
            // std.debug.print("{c}", .{ch});
            if (ch == '.' or ch == '\n' or ch == '\r') {
                if (num_start != null) {
                    const num = try std.fmt.parseInt(i32, line[num_start.?..i], 10);
                    // std.debug.print("\n{d}\n", .{num});
                    const nstart: i32 = @intCast(num_start.?);
                    const start = nstart - 1;
                    const end: i32 = @intCast(i + 1);
                    if ((num_start != 0 and line[num_start.? - 1] != '.') or range_contains(start, end, prev_line_symbols.data())) {
                        // std.debug.print("imm num {d}\n", .{num});
                        sum += num;
                    } else {
                        try this_line.append(NumRange{ .num = num, .min = start, .max = end });
                    }
                    num_start = null;
                }
            } else if ('0' <= ch and ch <= '9') {
                if (num_start == null) {
                    num_start = i;
                }
            } else {
                // std.debug.print("!{d}!", .{ch});
                if (num_start != null) {
                    const num = try std.fmt.parseInt(i32, line[num_start.?..i], 10);
                    // std.debug.print("\n{d}\n", .{num});
                    // std.debug.print("imm num 2 {d}\n", .{num});
                    sum += num;
                    num_start = null;
                }
                try this_line_symbols.append(@intCast(i));
            }
        }
        // std.debug.print("\n{any}\n", .{this_line_symbols.data()});
        for (prev_line.data()) |range| {
            if (range_contains(range.min, range.max, this_line_symbols.data())) {
                // std.debug.print("range num {d}\n", .{range.num});
                sum += range.num;
            } else {
                // std.debug.print("discarding {d} ({d}..{d})\n", .{ range.num, range.min, range.max });
            }
        }
        std.mem.swap(NumRangeBufList, &prev_line, &this_line);
        this_line.clear();
        std.mem.swap(IntBufList, &prev_line_symbols, &this_line_symbols);
        this_line_symbols.clear();
    }
    return sum;
}

const ThreeIntList = utils.BufferList(3, i32);

const RatioSpec = struct {
    idx: i32,
    nums: ThreeIntList,
};

pub fn part2(file: *std.fs.File) !i32 {
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    const NumRangeBufList = utils.BufferList(32, NumRange);
    var prev_line = NumRangeBufList.new();
    var this_line = NumRangeBufList.new();
    const RatioBufList = utils.BufferList(150, RatioSpec);
    var prev_line_symbols = RatioBufList.new();
    var this_line_symbols = RatioBufList.new();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var num_start: ?usize = null;
        for (line, 0..line.len) |ch, i| {
            // std.debug.print("{c}", .{ch});
            if (ch == '*') {
                try this_line_symbols.append(RatioSpec{ .idx = @intCast(i), .nums = ThreeIntList.new() });
            }
            if ('0' <= ch and ch <= '9') {
                if (num_start == null) {
                    num_start = i;
                }
            } else if (num_start != null) {
                const num = try std.fmt.parseInt(i32, line[num_start.?..i], 10);
                // std.debug.print("\n{d}\n", .{num});
                const start: i32 = @intCast(num_start.?);
                const end: i32 = @intCast(i + 1);
                try this_line.append(NumRange{ .num = num, .min = start - 1, .max = end });
                num_start = null;
            }
        }
        // std.debug.print("\n{any}\n", .{this_line_symbols.data()});
        outer: for (prev_line_symbols.data()) |*star| {
            for (this_line.data()) |range| {
                if (range.min <= star.idx and star.idx < range.max) {
                    star.nums.append(range.num) catch continue :outer;
                }
                if (star.idx < range.min) {
                    break;
                }
            }
            if (star.nums.len == 2) {
                const data = star.nums.data();
                sum += data[0] * data[1];
            }
        }
        outer: for (this_line_symbols.data()) |*star| {
            for (prev_line.data()) |range| {
                if (range.min <= star.idx and star.idx < range.max) {
                    star.nums.append(range.num) catch continue :outer;
                }
                if (star.idx < range.min) {
                    break;
                }
            }
            for (this_line.data()) |range| {
                if (range.min <= star.idx and star.idx < range.max) {
                    star.nums.append(range.num) catch continue :outer;
                }
                if (star.idx < range.min) {
                    break;
                }
            }
        }
        std.mem.swap(NumRangeBufList, &prev_line, &this_line);
        this_line.clear();
        std.mem.swap(RatioBufList, &prev_line_symbols, &this_line_symbols);
        this_line_symbols.clear();
    }
    return sum;
}
