const std = @import("std");
const utils = @import("utils.zig");

const Pos = struct {
    x: usize,
    y: usize,
};

fn neighbors(pos: Pos, size: Pos) [4]?Pos {
    var list: [4]?Pos = .{ null, null, null, null };
    if (pos.y != 0) {
        list[0] = Pos{ .x = pos.x, .y = pos.y - 1 };
    }
    if (pos.x + 1 < size.x) {
        list[1] = Pos{ .x = pos.x + 1, .y = pos.y };
    }
    if (pos.y + 1 < size.y) {
        list[2] = Pos{ .x = pos.x, .y = pos.y + 1 };
    }
    if (pos.x != 0) {
        list[3] = Pos{ .x = pos.x - 1, .y = pos.y };
    }
    return list;
}

fn get_pos(lines: *const std.ArrayList(std.ArrayList(u8)), pos: Pos) u8 {
    return lines.items[pos.y].items[pos.x];
}

const Dir = enum {
    North,
    East,
    South,
    West,
};

pub fn part1(file: *std.fs.File) !i32 {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    const sum: i32 = 0;
    _ = sum;
    var lines = std.ArrayList(std.ArrayList(u8)).init(alloc.allocator());
    defer lines.deinit();
    var start: Pos = undefined;
    var curr_line: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| : (curr_line += 1) {
        if (utils.find(line, 'S')) |index| {
            start = Pos{ .x = index, .y = curr_line };
        }
        var line_list = std.ArrayList(u8).init(alloc.allocator());
        try line_list.appendSlice(line[0 .. line.len - 1]);
        try lines.append(line_list);
    }
    std.debug.print("{any}\n", .{start});
    const size = Pos{ .x = lines.items[0].items.len, .y = lines.items.len };
    const first = neighbors(start, size);
    var path = std.ArrayList(Pos).init(alloc.allocator());
    var cur_pos = start;
    var to: Dir = undefined;
    std.debug.print("{c}\n", .{get_pos(&lines, cur_pos)});
    if (first[0]) |north| {
        const char = get_pos(&lines, north);
        std.debug.print("{c}\n", .{char});
        if (char == 'F' or char == '7' or char == '|') {
            cur_pos = north;
            to = Dir.North;
        }
    }
    if (first[1]) |east| {
        const char = get_pos(&lines, east);
        std.debug.print("{c}\n", .{char});
        if (char == 'J' or char == '7' or char == '-') {
            cur_pos = east;
            to = Dir.East;
        }
    }
    if (first[2]) |south| {
        const char = get_pos(&lines, south);
        std.debug.print("{c}\n", .{char});
        if (char == 'J' or char == 'L' or char == '|') {
            cur_pos = south;
            to = Dir.South;
        }
    }
    if (first[3]) |west| {
        const char = get_pos(&lines, west);
        std.debug.print("{c}\n", .{char});
        if (char == 'L' or char == 'F' or char == '-') {
            cur_pos = west;
            to = Dir.West;
        }
    }
    try path.append(cur_pos);
    var cur_symbol = get_pos(&lines, cur_pos);
    while (cur_symbol != 'S') {
        // std.debug.print("{c} {any} {any}\n", .{ cur_symbol, cur_pos, to });
        switch (to) {
            Dir.North => {
                if (cur_symbol == 'F') {
                    cur_pos.x += 1;
                    to = Dir.East;
                } else if (cur_symbol == '7') {
                    cur_pos.x -= 1;
                    to = Dir.West;
                } else if (cur_symbol == '|') {
                    cur_pos.y -= 1;
                }
            },
            Dir.East => {
                if (cur_symbol == 'J') {
                    cur_pos.y -= 1;
                    to = Dir.North;
                } else if (cur_symbol == '7') {
                    cur_pos.y += 1;
                    to = Dir.South;
                } else if (cur_symbol == '-') {
                    cur_pos.x += 1;
                }
            },
            Dir.South => {
                if (cur_symbol == 'J') {
                    cur_pos.x -= 1;
                    to = Dir.West;
                } else if (cur_symbol == 'L') {
                    cur_pos.x += 1;
                    to = Dir.East;
                } else if (cur_symbol == '|') {
                    cur_pos.y += 1;
                }
            },
            Dir.West => {
                if (cur_symbol == 'F') {
                    cur_pos.y += 1;
                    to = Dir.South;
                } else if (cur_symbol == 'L') {
                    cur_pos.y -= 1;
                    to = Dir.North;
                } else if (cur_symbol == '-') {
                    cur_pos.x -= 1;
                }
            },
        }
        try path.append(cur_pos);
        cur_symbol = get_pos(&lines, cur_pos);
    }

    // std.debug.print("{any}\n", .{path.items});
    var copy = std.ArrayList(std.ArrayList(u8)).init(alloc.allocator());
    for (lines.items) |line| {
        var cline = std.ArrayList(u8).init(alloc.allocator());
        try cline.appendNTimes('.', line.items.len);
        try copy.append(cline);
    }
    for (path.items) |p| {
        const c = get_pos(&lines, p);
        copy.items[p.y].items[p.x] = c;
    }
    for (copy.items) |c| {
        std.debug.print("{s}\n", .{c.items});
        c.deinit();
    }
    for (lines.items) |line| {
        line.deinit();
    }
    return @intCast(path.items.len / 2);
}

pub fn part2(file: *std.fs.File) !i32 {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var buf: [150]u8 = undefined;
    const reader = file.reader();
    const sum: i32 = 0;
    _ = sum;
    var lines = std.ArrayList(std.ArrayList(u8)).init(alloc.allocator());
    defer lines.deinit();
    var start: Pos = undefined;
    var curr_line: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| : (curr_line += 1) {
        if (utils.find(line, 'S')) |index| {
            start = Pos{ .x = index, .y = curr_line };
        }
        var line_list = std.ArrayList(u8).init(alloc.allocator());
        try line_list.appendSlice(line[0 .. line.len - 1]);
        try lines.append(line_list);
    }
    std.debug.print("{any}\n", .{start});
    const size = Pos{ .x = lines.items[0].items.len, .y = lines.items.len };
    const first = neighbors(start, size);
    var path = std.ArrayList(Pos).init(alloc.allocator());
    var cur_pos = start;
    var to: Dir = undefined;
    std.debug.print("{c}\n", .{get_pos(&lines, cur_pos)});
    var start_char: u8 = 0;
    if (first[0]) |north| {
        const char = get_pos(&lines, north);
        std.debug.print("{c}\n", .{char});
        if (char == 'F' or char == '7' or char == '|') {
            cur_pos = north;
            to = Dir.North;
            start_char = 'N';
        }
    }
    if (first[1]) |east| {
        const char = get_pos(&lines, east);
        std.debug.print("{c}\n", .{char});
        if (char == 'J' or char == '7' or char == '-') {
            cur_pos = east;
            to = Dir.East;
            if (start_char == 'N') {
                start_char = 'L';
            } else {
                start_char = 'E';
            }
        }
    }
    if (first[2]) |south| {
        const char = get_pos(&lines, south);
        std.debug.print("{c}\n", .{char});
        if (char == 'J' or char == 'L' or char == '|') {
            cur_pos = south;
            to = Dir.South;
            if (start_char == 'N') {
                start_char = '|';
            } else if (start_char == 'E') {
                start_char = 'F';
            } else if (start_char == 0) {
                start_char = 'S';
            }
        }
    }
    if (first[3]) |west| {
        const char = get_pos(&lines, west);
        std.debug.print("{c}\n", .{char});
        if (char == 'L' or char == 'F' or char == '-') {
            cur_pos = west;
            to = Dir.West;
            if (start_char == 'N') {
                start_char = 'J';
            } else if (start_char == 'E') {
                start_char = '-';
            } else if (start_char == 'S') {
                start_char = '7';
            }
        }
    }
    try path.append(cur_pos);
    var cur_symbol = get_pos(&lines, cur_pos);
    while (cur_symbol != 'S') {
        // std.debug.print("{c} {any} {any}\n", .{ cur_symbol, cur_pos, to });
        switch (to) {
            Dir.North => {
                if (cur_symbol == 'F') {
                    cur_pos.x += 1;
                    to = Dir.East;
                } else if (cur_symbol == '7') {
                    cur_pos.x -= 1;
                    to = Dir.West;
                } else if (cur_symbol == '|') {
                    cur_pos.y -= 1;
                }
            },
            Dir.East => {
                if (cur_symbol == 'J') {
                    cur_pos.y -= 1;
                    to = Dir.North;
                } else if (cur_symbol == '7') {
                    cur_pos.y += 1;
                    to = Dir.South;
                } else if (cur_symbol == '-') {
                    cur_pos.x += 1;
                }
            },
            Dir.South => {
                if (cur_symbol == 'J') {
                    cur_pos.x -= 1;
                    to = Dir.West;
                } else if (cur_symbol == 'L') {
                    cur_pos.x += 1;
                    to = Dir.East;
                } else if (cur_symbol == '|') {
                    cur_pos.y += 1;
                }
            },
            Dir.West => {
                if (cur_symbol == 'F') {
                    cur_pos.y += 1;
                    to = Dir.South;
                } else if (cur_symbol == 'L') {
                    cur_pos.y -= 1;
                    to = Dir.North;
                } else if (cur_symbol == '-') {
                    cur_pos.x -= 1;
                }
            },
        }
        try path.append(cur_pos);
        cur_symbol = get_pos(&lines, cur_pos);
    }

    // std.debug.print("{any}\n", .{path.items});
    var copy = std.ArrayList(std.ArrayList(u8)).init(alloc.allocator());
    for (lines.items) |line| {
        var cline = std.ArrayList(u8).init(alloc.allocator());
        try cline.appendNTimes('.', line.items.len);
        try copy.append(cline);
    }
    for (path.items) |p| {
        const c = get_pos(&lines, p);
        copy.items[p.y].items[p.x] = c;
    }
    const last = path.getLast();
    copy.items[last.y].items[last.x] = start_char;
    var inside_count: i32 = 0;
    for (copy.items) |c| {
        var inside = false;
        var enter: u8 = 0;
        for (c.items) |ch| {
            switch (ch) {
                'F' => {
                    enter = 'F';
                },
                'L' => {
                    enter = 'L';
                },
                'J' => {
                    if (enter == 'F') {
                        inside = !inside;
                    }
                },
                '7' => {
                    if (enter == 'L') {
                        inside = !inside;
                    }
                },
                '|' => {
                    inside = !inside;
                },
                '.' => {
                    if (inside) {
                        inside_count += 1;
                    }
                },
                else => {},
            }
        }
        // std.debug.print("{s}\n", .{c.items});
        c.deinit();
    }
    for (lines.items) |line| {
        line.deinit();
    }
    return inside_count;
}
