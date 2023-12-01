const std = @import("std");

pub fn part1(file: *std.fs.File) !i32 {
    var buf: [100]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var start: ?u8 = null;
        var end: u8 = undefined;
        for (line) |ch| {
            if ('0' < ch and ch <= '9') {
                if (start == null) {
                    start = ch - '0';
                }
                end = ch - '0';
            }
        }
        const line_val = start.? * 10 + end;
        sum += line_val;
    }
    return sum;
}

pub fn part2(file: *std.fs.File) !i32 {
    var buf: [100]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var start: ?u8 = null;
        var end: u8 = undefined;
        for (line, 0..line.len) |ch, i| {
            var this_num: ?u8 = null;
            if ('0' < ch and ch <= '9') {
                this_num = ch - '0';
            } else {
                if (i + 3 <= line.len) {
                    if (std.mem.eql(u8, line[i .. i + 3], "one")) {
                        this_num = 1;
                    } else if (std.mem.eql(u8, line[i .. i + 3], "two")) {
                        this_num = 2;
                    } else if (std.mem.eql(u8, line[i .. i + 3], "six")) {
                        this_num = 6;
                    }
                }
                if (i + 4 <= line.len) {
                    if (std.mem.eql(u8, line[i .. i + 4], "four")) {
                        this_num = 4;
                    } else if (std.mem.eql(u8, line[i .. i + 4], "five")) {
                        this_num = 5;
                    } else if (std.mem.eql(u8, line[i .. i + 4], "nine")) {
                        this_num = 9;
                    }
                }
                if (i + 5 <= line.len) {
                    if (std.mem.eql(u8, line[i .. i + 5], "three")) {
                        this_num = 3;
                    } else if (std.mem.eql(u8, line[i .. i + 5], "seven")) {
                        this_num = 7;
                    } else if (std.mem.eql(u8, line[i .. i + 5], "eight")) {
                        this_num = 8;
                    }
                }
            }
            if (this_num) |num| {
                if (start == null) {
                    start = num;
                }
                end = num;
            }
        }
        const line_val = start.? * 10 + end;
        std.debug.print("{d}\n", .{line_val});
        sum += line_val;
    }
    return sum;
}
