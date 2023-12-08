const std = @import("std");
const root = @import("root.zig");

const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");
const day7 = @import("day7.zig");
const day8 = @import("day8.zig");

fn callDay(day: u8, part: u8, file: *std.fs.File) !i32 {
    switch (day) {
        1 => if (part == 1) {
            return try day1.part1(file);
        } else if (part == 2) {
            return try day1.part2(file);
        } else {
            return error.partOutOfRange;
        },
        2 => if (part == 1) {
            return try day2.part1(file);
        } else if (part == 2) {
            return try day2.part2(file);
        } else {
            return error.partOutOfRange;
        },
        3 => if (part == 1) {
            return try day3.part1(file);
        } else if (part == 2) {
            return try day3.part2(file);
        } else {
            return error.partOutOfRange;
        },
        4 => if (part == 1) {
            return try day4.part1(file);
        } else if (part == 2) {
            return try day4.part2(file);
        } else {
            return error.partOutOfRange;
        },
        5 => if (part == 1) {
            return try day5.part1(file);
        } else if (part == 2) {
            return try day5.part2(file);
        } else {
            return error.partOutOfRange;
        },
        6 => if (part == 1) {
            return try day6.part1(file);
        } else if (part == 2) {
            return try day6.part2(file);
        } else {
            return error.partOutOfRange;
        },
        7 => if (part == 1) {
            return try day7.part1(file);
        } else if (part == 2) {
            return try day7.part2(file);
        } else {
            return error.partOutOfRange;
        },
        8 => if (part == 1) {
            return try day8.part1(file);
        } else if (part == 2) {
            return try day8.part2(file);
        } else {
            return error.partOutOfRange;
        },
        else => {
            return error.dayOutOfRange;
        },
    }
    unreachable;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var args = try std.process.argsWithAllocator(gpa.allocator());
    defer args.deinit();
    _ = args.next();
    const day = try std.fmt.parseInt(u8, args.next().?, 10);
    const part = try std.fmt.parseInt(u8, args.next().?, 10);
    const filepath = args.next().?;
    var file = try std.fs.cwd().openFile(filepath, .{});
    const result = try callDay(day, part, &file);
    const stdout_writer = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_writer);
    const stdout = bw.writer();
    try stdout.print("{d}", .{result});
    try bw.flush();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
