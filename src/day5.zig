const std = @import("std");
const utils = @import("utils.zig");

pub fn Range(comptime T: type) type {
    return struct {
        start: T,
        end: T,
    };
}

fn lower_bound(key: u32, items: []const u32) usize {
    var left: usize = 0;
    var right: usize = items.len;

    while (left < right) {
        // Avoid overflowing in the midpoint calculation
        const mid = left + (right - left) / 2;
        // Compare the key with the midpoint element
        if (items[mid] == key) {
            return mid;
        } else if (items[mid] < key) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }
    return right;
}

fn upper_bound(key: u32, items: []const u32) usize {
    var left: usize = 0;
    var right: usize = items.len;

    while (left < right) {
        // Avoid overflowing in the midpoint calculation
        const mid = left + (right - left) / 2;
        // Compare the key with the midpoint element
        if (items[mid] == key) {
            return mid;
        } else if (items[mid] < key) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }
    return left;
}

fn binary_search_range(items: []const u32, range: Range(u32)) Range(usize) {
    const start = lower_bound(range.start, items);
    const end = upper_bound(range.end, items[start..]);
    return Range(usize){
        .start = start,
        .end = start + end,
    };
}

fn u32compare(_: @TypeOf(.{}), a: u32, b: u32) bool {
    return a < b;
}

pub fn part1(file: *std.fs.File) !i32 {
    var buf: [300]u8 = undefined;
    const reader = file.reader();
    const sum = 0;
    _ = sum;

    const u32List = std.ArrayList(u32);
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var this_type = u32List.init(alloc.allocator());
    defer this_type.deinit();
    var next_type = u32List.init(alloc.allocator());
    defer next_type.deinit();

    var first_line = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
    first_line = first_line[utils.find(first_line, ' ').? + 1 ..];
    while (std.ascii.isDigit(first_line[0])) {
        if (utils.find(first_line, ' ')) |next_space| {
            const num = try std.fmt.parseInt(u32, first_line[0..next_space], 10);
            try this_type.append(num);
            first_line = first_line[next_space + 1 ..];
        } else {
            const num_end = utils.find(first_line, '\r') orelse {
                std.debug.print("{any}\n", .{first_line});
                return error.er;
            };
            const num = try std.fmt.parseInt(u32, first_line[0..num_end], 10);
            try this_type.append(num);
            break;
        }
    }
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
    std.sort.block(u32, this_type.items, .{}, u32compare);
    for (this_type.items) |e| {
        try next_type.append(e);
    }
    // std.debug.print("{any}\n", .{this_type.items});

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len <= 3) {
            std.sort.block(u32, next_type.items, .{}, u32compare);
            std.mem.copyForwards(u32, this_type.items, next_type.items);
            // std.debug.print("{any}\n", .{this_type.items});
            _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
            continue;
        }
        var numstr = line;
        const num1_end = utils.find(numstr, ' ').?;
        const dest_start = try std.fmt.parseInt(u32, numstr[0..num1_end], 10);
        numstr = numstr[num1_end + 1 ..];
        const num2_end = utils.find(numstr, ' ').?;
        const source_start = try std.fmt.parseInt(u32, numstr[0..num2_end], 10);
        numstr = numstr[num2_end + 1 ..];
        const num3_end = utils.find(numstr, '\r').?;
        const len = try std.fmt.parseInt(u32, numstr[0..num3_end], 10);
        // std.debug.print("{d}..{d} -> {d}..{d}\n", .{ source_start, source_start + len, dest_start, dest_start + len });
        const range = binary_search_range(this_type.items, Range(u32){ .start = source_start, .end = source_start +| len });
        // std.debug.print("{d}..{d}\n", .{ range.start, range.end });
        for (range.start..range.end) |i| {
            next_type.items[i] = this_type.items[i] - source_start + dest_start;
        }
    }
    return @intCast(this_type.items[0]);
}

// fn lower_range_bound(key: u32, items: []const Range(u32)) usize {
//     var left: usize = 0;
//     var right: usize = items.len;

//     while (left < right) {
//         // Avoid overflowing in the midpoint calculation
//         const mid = left + (right - left) / 2;
//         // Compare the key with the midpoint element
//         if (items[mid].start == key) {
//             return mid;
//         } else if (items[mid].start < key) {
//             left = mid + 1;
//         } else {
//             right = mid;
//         }
//     }
//     return right;
// }

// fn upper_range_bound(key: u32, items: []const Range(u32)) usize {
//     var left: usize = 0;
//     var right: usize = items.len;

//     while (left < right) {
//         // Avoid overflowing in the midpoint calculation
//         const mid = left + (right - left) / 2;
//         // Compare the key with the midpoint element
//         if (items[mid].end == key) {
//             return mid;
//         } else if (items[mid].end < key) {
//             left = mid + 1;
//         } else {
//             right = mid;
//         }
//     }
//     return left;
// }

// fn binary_search_range_2(items: []const Range(u32), range: Range(u32)) Range(usize) {
//     const start = lower_bound(range.start, items);
//     const end = upper_bound(range.end, items[start..]);
//     return Range(usize){
//         .start = start,
//         .end = start + end,
//     };
// }

fn range_contains(range: Range(i64), val: i64) bool {
    return range.start <= val and range.end > val;
}

const RangeList = utils.BufferList(3, [2]Range(i64));
fn range_overlap(a: Range(i64), b: Range(i64), offset: i64) RangeList {
    var list = RangeList{};
    if (b.start <= a.start and a.end <= b.end) {
        // full overlap
        list.append(.{ a, Range(i64){ .start = a.start + offset, .end = a.end + offset } }) catch unreachable;
    } else if (b.start <= a.start) {
        if (b.end > a.start) {
            // first half of a overlaps
            list.append(.{ Range(i64){ .start = a.start, .end = b.end }, Range(i64){ .start = a.start + offset, .end = b.end + offset } }) catch unreachable;
            list.append(.{ Range(i64){ .start = b.end, .end = a.end }, Range(i64){ .start = b.end, .end = a.end } }) catch unreachable;
        } else {
            // b < a
            // list.append(.{ a, a }) catch unreachable;
        }
    } else if (a.end <= b.end) {
        if (b.start < a.end) {
            // second half of a overlaps
            list.append(.{ Range(i64){ .start = a.start, .end = b.start }, Range(i64){ .start = a.start, .end = b.start } }) catch unreachable;
            list.append(.{ Range(i64){ .start = b.start, .end = a.end }, Range(i64){ .start = b.start + offset, .end = a.end + offset } }) catch unreachable;
        } else {
            // a < b
            // list.append(.{ a, a }) catch unreachable;
        }
    } else {
        // b ⊂ a
        list.append(.{ Range(i64){ .start = a.start, .end = b.start }, Range(i64){ .start = a.start, .end = b.start } }) catch unreachable;
        list.append(.{ Range(i64){ .start = b.end, .end = a.end }, Range(i64){ .start = b.end, .end = a.end } }) catch unreachable;
        list.append(.{ Range(i64){ .start = b.start, .end = b.start }, Range(i64){ .start = b.start + offset, .end = b.start + offset } }) catch unreachable;
    }
    return list;
}

fn range_less(_: @TypeOf(.{}), lhs: Range(i64), rhs: Range(i64)) bool {
    return lhs.start < rhs.start;
}

pub fn part2(file: *std.fs.File) !i32 {
    var buf: [300]u8 = undefined;
    const reader = file.reader();
    const sum = 0;
    _ = sum;

    const i64RangeList = std.ArrayList(Range(i64));
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var this_type = i64RangeList.init(alloc.allocator());
    defer this_type.deinit();
    var next_type = i64RangeList.init(alloc.allocator());
    defer next_type.deinit();

    var first_line = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
    first_line = first_line[utils.find(first_line, ' ').? + 1 ..];
    var first_num: ?i64 = null;
    while (std.ascii.isDigit(first_line[0])) {
        if (utils.find(first_line, ' ')) |next_space| {
            const num = try std.fmt.parseInt(i64, first_line[0..next_space], 10);
            if (first_num) |first| {
                try this_type.append(Range(i64){ .start = first, .end = first + num });
                first_num = null;
            } else {
                first_num = num;
            }
            first_line = first_line[next_space + 1 ..];
        } else {
            const num_end = utils.find(first_line, '\r') orelse {
                std.debug.print("{any}\n", .{first_line});
                return error.er;
            };
            const num = try std.fmt.parseInt(i64, first_line[0..num_end], 10);
            try this_type.append(Range(i64){ .start = first_num.?, .end = first_num.? + num });
            break;
        }
    }
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
    _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
    std.sort.block(Range(i64), this_type.items, .{}, range_less);
    for (this_type.items) |e| {
        try next_type.append(e);
    }
    std.debug.print("{any}\n", .{this_type.items});

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len <= 3) {
            std.sort.block(Range(i64), next_type.items, .{}, range_less);
            this_type.items.len = 0;
            try this_type.append(next_type.items[0]);
            for (next_type.items) |item| {
                const last = this_type.getLast();
                if (last.end >= item.start) {
                    if (last.end < item.end) {
                        this_type.items[this_type.items.len - 1].end = item.end;
                    }
                } else {
                    try this_type.append(item);
                }
            }
            next_type.items.len = this_type.items.len;
            std.mem.copyForwards(Range(i64), next_type.items, this_type.items);
            // std.debug.print("Done: {any}\n", .{this_type.items});
            _ = try reader.readUntilDelimiterOrEof(&buf, '\n');
            continue;
        }
        var numstr = line;
        const num1_end = utils.find(numstr, ' ').?;
        const dest_start = try std.fmt.parseInt(i64, numstr[0..num1_end], 10);
        numstr = numstr[num1_end + 1 ..];
        const num2_end = utils.find(numstr, ' ').?;
        const source_start = try std.fmt.parseInt(i64, numstr[0..num2_end], 10);
        numstr = numstr[num2_end + 1 ..];
        const num3_end = utils.find(numstr, '\r').?;
        const len = try std.fmt.parseInt(i64, numstr[0..num3_end], 10);
        const offset = dest_start - source_start;
        const source_range = Range(i64){ .start = source_start, .end = source_start +| len };
        std.debug.print("{d}..{d}: +{d}\n", .{ source_start, source_start + len, offset });
        var i: isize = @intCast(this_type.items.len - 1);
        while (i >= 0) : (i -= 1) {
            var new_ranges = range_overlap(this_type.items[@intCast(i)], source_range, offset);
            if (new_ranges.pop()) |first| {
                this_type.items[@intCast(i)] = first[0];
                next_type.items[@intCast(i)] = first[1];
                while (new_ranges.pop()) |range| {
                    try this_type.append(range[0]);
                    try next_type.append(range[1]);
                }
            }
        }
        // std.debug.print("{any}\n{any}\n", .{ this_type.items, next_type.items });
    }
    const min_idx = std.sort.argMin(Range(i64), this_type.items, .{}, range_less).?;
    return @intCast(this_type.items[min_idx].start);
}
