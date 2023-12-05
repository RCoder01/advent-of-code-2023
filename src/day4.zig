const std = @import("std");
const utils = @import("utils.zig");

fn lstrip_space(str: []u8) []u8 {
    var trimmed = str;
    while (trimmed[0] == ' ') {
        trimmed = trimmed[1..];
    }
    return trimmed;
}

pub fn part1(file: *std.fs.File) !i32 {
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    const ByteList = utils.BufferList(10, u8);
    var winning_arr: [100]bool = [1]bool{false} ** 100;
    // std.mem.zeroes(comptime T: type)
    var winning_nums = ByteList{};
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var rem = line;
        const first = utils.find(rem, ':') orelse return error.MissingCharacter;
        rem = rem[first + 2 ..];
        while (rem[0] != '|') {
            const n = try std.fmt.parseInt(u8, lstrip_space(rem[0..2]), 10);
            try winning_nums.append(n);
            winning_arr[@intCast(n)] = true;
            rem = rem[3..];
        }
        // std.debug.print("winning {any}\n", .{winning_nums.data()});
        rem = rem[1..];
        var line_value: i32 = 1;
        while (rem[0] > std.ascii.control_code.cr) {
            // std.debug.print("d0 {d}\n", .{rem[0]});
            const n = try std.fmt.parseInt(u8, lstrip_space(rem[0..3]), 10);
            if (winning_arr[@intCast(n)]) {
                line_value <<= 1;
            }
            rem = rem[3..];
        }
        for (winning_nums.data()) |num| {
            winning_arr[@intCast(num)] = false;
        }
        winning_nums.clear();
        sum += line_value >> 1;
    }
    return sum;
}

pub fn part2(file: *std.fs.File) !i32 {
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    var winning_arr: [100]bool = [1]bool{false} ** 100;
    // std.mem.zeroes(comptime T: type)
    const ByteList = utils.BufferList(10, u8);
    var winning_nums = ByteList{};
    const i32List = std.ArrayList(i32);
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var counts = i32List.init(alloc.allocator());
    defer counts.deinit();
    var curr_line: i32 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (counts.items.len <= curr_line) {
            try counts.append(1);
        }
        var rem = line;
        const first = utils.find(rem, ':') orelse return error.MissingCharacter;
        rem = rem[first + 2 ..];
        while (rem[0] != '|') {
            const n = try std.fmt.parseInt(u8, lstrip_space(rem[0..2]), 10);
            try winning_nums.append(n);
            winning_arr[@intCast(n)] = true;
            rem = rem[3..];
        }
        // std.debug.print("winning {any}\n", .{winning_nums.data()});
        rem = rem[1..];
        var matches: i32 = 0;
        while (rem[0] > std.ascii.control_code.cr) {
            // std.debug.print("d0 {d}\n", .{rem[0]});
            const n = try std.fmt.parseInt(u8, lstrip_space(rem[0..3]), 10);
            if (winning_arr[@intCast(n)]) {
                matches += 1;
            }
            rem = rem[3..];
        }
        for (winning_nums.data()) |num| {
            winning_arr[@intCast(num)] = false;
        }
        winning_nums.clear();
        for (0..@intCast(matches)) |i| {
            const start: usize = @intCast(curr_line + 1);
            if (counts.items.len <= start + i) {
                try counts.append(1);
            }
            counts.items[start + i] += counts.items[@intCast(curr_line)];
        }
        sum += counts.items[@intCast(curr_line)];
        curr_line += 1;
    }
    return sum;
}
