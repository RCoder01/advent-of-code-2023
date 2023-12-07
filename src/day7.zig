const std = @import("std");
const utils = @import("utils.zig");

const card_val_map_1: [35]u8 = .{ 0, 1, 2, 3, 4, 5, 6, 7, 0, 0, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 9, 11, 0, 0, 0, 0, 0, 10, 0, 0, 8 };
const card_val_map_2: [35]u8 = .{ 1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, 10, 0, 0, 9 };

const CardCount = struct {
    card: u8,
    count: u8,
};

fn card_count_compare(_: void, a: CardCount, b: CardCount) bool {
    return a.count > b.count;
}

const CardCountList = utils.BufferList(5, CardCount);

const CardVal = struct {
    cards: [5]u8,
    value: i32,
    const Self = @This();

    fn counts(self: *const Self) CardCountList {
        var list = CardCountList{};
        for (self.cards) |card| {
            for (list.data()) |*it| {
                if (it.card == card) {
                    it.count += 1;
                    break;
                }
            } else {
                list.append(CardCount{ .card = card, .count = 1 }) catch unreachable;
            }
        }
        std.sort.insertion(CardCount, list.data(), {}, card_count_compare);
        return list;
    }

    fn val_at(self: *const Self, index: usize) u8 {
        return card_val_map_1[self.cards[index] - '2'];
    }

    fn val_at_2(self: *const Self, index: usize) u8 {
        return card_val_map_2[self.cards[index] - '2'];
    }
};

const Type = enum {
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind,

    fn from_counts(cards: *const CardCountList) Type {
        const card_counts = cards.const_data();
        if (card_counts[0].count == 5) {
            return Type.FiveOfAKind;
        } else if (card_counts[0].count == 4) {
            return Type.FourOfAKind;
        } else if (card_counts[0].count == 3 and card_counts[1].count == 2) {
            return Type.FullHouse;
        } else if (card_counts[0].count == 3) {
            return Type.ThreeOfAKind;
        } else if (card_counts[0].count == 2 and card_counts[1].count == 2) {
            return Type.TwoPair;
        } else if (card_counts[0].count == 2) {
            return Type.OnePair;
        } else {
            return Type.HighCard;
        }
    }

    fn from_counts_2(cards: *const CardCountList) Type {
        const card_counts = cards.const_data();
        if (card_counts[0].count == 5) {
            return Type.FiveOfAKind;
        } else if (card_counts[0].count == 4) {
            if (card_counts[0].card == 'J' or card_counts[1].card == 'J') {
                return Type.FiveOfAKind;
            }
            return Type.FourOfAKind;
        } else if (card_counts[0].count == 3 and card_counts[1].count == 2) {
            if (card_counts[0].card == 'J' or card_counts[1].card == 'J') {
                return Type.FiveOfAKind;
            }
            return Type.FullHouse;
        } else if (card_counts[0].count == 3) {
            if (card_counts[0].card == 'J' or card_counts[1].card == 'J' or card_counts[2].card == 'J') {
                return Type.FourOfAKind;
            }
            return Type.ThreeOfAKind;
        } else if (card_counts[0].count == 2 and card_counts[1].count == 2) {
            if (card_counts[0].card == 'J' or card_counts[1].card == 'J') {
                return Type.FourOfAKind;
            }
            if (card_counts[2].card == 'J') {
                return Type.FullHouse;
            }
            return Type.TwoPair;
        } else if (card_counts[0].count == 2) {
            if (card_counts[0].card == 'J' or card_counts[1].card == 'J' or card_counts[2].card == 'J' or card_counts[3].card == 'J') {
                return Type.ThreeOfAKind;
            }
            return Type.OnePair;
        } else {
            if (card_counts[0].card == 'J' or card_counts[1].card == 'J' or card_counts[2].card == 'J' or card_counts[3].card == 'J' or card_counts[4].card == 'J') {
                return Type.OnePair;
            }
            return Type.HighCard;
        }
    }
};

fn card_compare(_: @TypeOf(.{}), a: CardVal, b: CardVal) bool {
    const a_type = Type.from_counts(&a.counts());
    const b_type = Type.from_counts(&b.counts());
    if (a_type == b_type) {
        for (0..5) |i| {
            const a_val = a.val_at(i);
            const b_val = b.val_at(i);
            if (a_val == b_val) {
                continue;
            } else {
                return a_val < b_val;
            }
        }
    } else {
        return @intFromEnum(a_type) < @intFromEnum(b_type);
    }
    unreachable;
}

pub fn part1(file: *std.fs.File) !i32 {
    var buf: [15]u8 = undefined;
    const reader = file.reader();

    const CardList = std.ArrayList(CardVal);
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var cards = CardList.init(alloc.allocator());
    defer cards.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const card = line[0..5];
        const numstr = line[6 .. line.len - 1];
        const num = try std.fmt.parseInt(i32, numstr, 10);
        try cards.append(CardVal{ .cards = undefined, .value = num });
        std.mem.copyForwards(u8, &cards.items[cards.items.len - 1].cards, card);
    }
    std.sort.insertion(CardVal, cards.items, .{}, card_compare);
    // std.debug.print("{any}\n", .{cards.items});
    // for (cards.items) |it| {
    //     const counts = it.counts();
    //     std.debug.print("{any} {any}\n", .{ counts, Type.from_counts(&counts) });
    // }

    var sum: i32 = 0;
    for (cards.items, 0..cards.items.len) |card, i| {
        const mul: i32 = @intCast(i);
        sum += card.value * (mul + 1);
    }
    return sum;
}

fn card_compare_2(_: @TypeOf(.{}), a: CardVal, b: CardVal) bool {
    const a_type = Type.from_counts_2(&a.counts());
    const b_type = Type.from_counts_2(&b.counts());
    if (a_type == b_type) {
        for (0..5) |i| {
            const a_val = a.val_at_2(i);
            const b_val = b.val_at_2(i);
            if (a_val == b_val) {
                continue;
            } else {
                return a_val < b_val;
            }
        }
    } else {
        return @intFromEnum(a_type) < @intFromEnum(b_type);
    }
    unreachable;
}

pub fn part2(file: *std.fs.File) !i32 {
    var buf: [15]u8 = undefined;
    const reader = file.reader();

    const CardList = std.ArrayList(CardVal);
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var cards = CardList.init(alloc.allocator());
    defer cards.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const card = line[0..5];
        const numstr = line[6 .. line.len - 1];
        const num = try std.fmt.parseInt(i32, numstr, 10);
        try cards.append(CardVal{ .cards = undefined, .value = num });
        std.mem.copyForwards(u8, &cards.items[cards.items.len - 1].cards, card);
    }
    std.sort.insertion(CardVal, cards.items, .{}, card_compare_2);
    std.debug.print("{any}\n", .{cards.items});
    for (cards.items) |it| {
        const counts = it.counts();
        std.debug.print("{s} {any} {any}\n", .{ it.cards, counts, Type.from_counts_2(&counts) });
    }

    var sum: i32 = 0;
    for (cards.items, 0..cards.items.len) |card, i| {
        const mul: i32 = @intCast(i);
        sum += card.value * (mul + 1);
    }
    return sum;
}
