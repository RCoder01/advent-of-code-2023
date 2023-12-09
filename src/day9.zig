const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(file: *std.fs.File) !i32 {
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var derivatives = std.ArrayList(i32).init(alloc.allocator());
    defer derivatives.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var num_iter = utils.SplitNums(i32){ .line = line };
        while (try num_iter.next()) |next| {
            var next_num = next;
            for (derivatives.items) |*d| {
                const temp = next_num - d.*;
                d.* = next_num;
                next_num = temp;
            }
            try derivatives.append(next_num);
        }
        var i = derivatives.items.len - 1;
        while (i > 0) : (i -= 1) {
            derivatives.items[i - 1] += derivatives.items[i];
        }
        sum += derivatives.items[0];
        derivatives.clearRetainingCapacity();
    }
    return sum;
}

pub fn part2(file: *std.fs.File) !i32 {
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var derivatives = std.ArrayList(i32).init(alloc.allocator());
    defer derivatives.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var num_iter = utils.SplitNums(i32){ .line = line };
        var count: usize = 0;
        while (try num_iter.next()) |next| {
            var next_num = next;
            for (derivatives.items) |*d| {
                const temp = next_num - d.*;
                d.* = next_num;
                next_num = temp;
            }
            try derivatives.append(next_num);
            count += 1;
        }
        for (0..count) |_| {
            for (0..derivatives.items.len - 2) |i| {
                derivatives.items[i] -= derivatives.items[i + 1];
            }
        }
        sum += derivatives.items[0];
        derivatives.clearRetainingCapacity();
    }
    return sum;
}
