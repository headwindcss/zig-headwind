const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const flexbox = headwind.flexbox;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Flex Direction Tests
// ============================================================================

test "flex direction values" {
    const allocator = testing.allocator;

    const directions = [_]struct { class: []const u8, expected: []const u8 }{
        .{ .class = "flex-row", .expected = "row" },
        .{ .class = "flex-row-reverse", .expected = "row-reverse" },
        .{ .class = "flex-col", .expected = "column" },
        .{ .class = "flex-col-reverse", .expected = "column-reverse" },
    };

    for (directions) |dir| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, dir.class);
        defer parsed.deinit(allocator);

        try flexbox.generateFlexDirection(&generator, &parsed, dir.expected);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "flex-direction") != null);
        try testing.expect(std.mem.indexOf(u8, css, dir.expected) != null);
    }
}

// ============================================================================
// Flex Wrap Tests
// ============================================================================

test "flex wrap values" {
    const allocator = testing.allocator;

    const wraps = [_]struct { class: []const u8, expected: []const u8 }{
        .{ .class = "flex-wrap", .expected = "wrap" },
        .{ .class = "flex-wrap-reverse", .expected = "wrap-reverse" },
        .{ .class = "flex-nowrap", .expected = "nowrap" },
    };

    for (wraps) |wrap| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, wrap.class);
        defer parsed.deinit(allocator);

        try flexbox.generateFlexWrap(&generator, &parsed, wrap.expected);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "flex-wrap") != null);
    }
}

// ============================================================================
// Flex Tests
// ============================================================================

test "flex values" {
    const allocator = testing.allocator;

    const flex_values = [_]struct { class: []const u8, value: []const u8 }{
        .{ .class = "flex-1", .value = "1 1 0%" },
        .{ .class = "flex-auto", .value = "1 1 auto" },
        .{ .class = "flex-initial", .value = "0 1 auto" },
        .{ .class = "flex-none", .value = "none" },
    };

    for (flex_values) |flex_val| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, flex_val.class);
        defer parsed.deinit(allocator);

        try flexbox.generateFlex(&generator, &parsed, flex_val.value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "flex:") != null);
    }
}

// ============================================================================
// Flex Grow/Shrink Tests
// ============================================================================

test "flex grow values" {
    const allocator = testing.allocator;

    const grows = [_][]const u8{ "0", "1" };

    for (grows) |grow| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "flex-grow-{s}", .{grow});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try flexbox.generateFlexGrow(&generator, &parsed, grow);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "flex-grow") != null);
    }
}

test "flex shrink values" {
    const allocator = testing.allocator;

    const shrinks = [_][]const u8{ "0", "1" };

    for (shrinks) |shrink| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "flex-shrink-{s}", .{shrink});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try flexbox.generateFlexShrink(&generator, &parsed, shrink);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "flex-shrink") != null);
    }
}

// ============================================================================
// Justify Content Tests
// ============================================================================

test "justify content values" {
    const allocator = testing.allocator;

    const justifies = [_][]const u8{
        "start",   "end",    "center",  "between",
        "around",  "evenly", "stretch",
    };

    for (justifies) |justify| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "justify-{s}", .{justify});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try flexbox.generateJustifyContent(&generator, &parsed, justify);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "justify-content") != null);
    }
}

// ============================================================================
// Align Items Tests
// ============================================================================

test "align items values" {
    const allocator = testing.allocator;

    const aligns = [_][]const u8{
        "start", "end", "center", "baseline", "stretch",
    };

    for (aligns) |align_value| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "items-{s}", .{align_value});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try flexbox.generateAlignItems(&generator, &parsed, align_value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "align-items") != null);
    }
}

// ============================================================================
// Align Self Tests
// ============================================================================

test "align self values" {
    const allocator = testing.allocator;

    const aligns = [_][]const u8{
        "auto", "start", "end", "center", "stretch", "baseline",
    };

    for (aligns) |align_value| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "self-{s}", .{align_value});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try flexbox.generateAlignSelf(&generator, &parsed, align_value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "align-self") != null);
    }
}

// ============================================================================
// Gap Tests
// ============================================================================

test "gap values" {
    const allocator = testing.allocator;

    const gaps = [_][]const u8{ "0", "1", "2", "4", "8", "16" };

    for (gaps) |gap| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "gap-{s}", .{gap});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try flexbox.generateGap(&generator, &parsed, gap);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "gap") != null);
    }
}

test "gap directional" {
    const allocator = testing.allocator;

    const directions = [_]struct { prefix: []const u8, prop: []const u8 }{
        .{ .prefix = "gap-x", .prop = "column-gap" },
        .{ .prefix = "gap-y", .prop = "row-gap" },
    };

    for (directions) |dir| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "{s}-4", .{dir.prefix});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try flexbox.generateGap(&generator, &parsed, "4");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, dir.prop) != null);
    }
}

// ============================================================================
// Order Tests
// ============================================================================

test "order values" {
    const allocator = testing.allocator;

    const orders = [_][]const u8{
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12",
        "first", "last", "none",
    };

    for (orders) |order| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "order-{s}", .{order});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try flexbox.generateOrder(&generator, &parsed, order);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "order") != null);
    }
}
