const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const spacing = headwind.spacing;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Margin Tests
// ============================================================================

test "margin all sides" {
    const allocator = testing.allocator;

    const margins = [_][]const u8{
        "0",  "1",  "2",  "3",  "4",  "5",  "6",  "8",  "10", "12",
        "14", "16", "20", "24", "28", "32", "36", "40", "44", "48",
        "52", "56", "60", "64", "72", "80", "96", "auto",
    };

    for (margins) |margin| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "m-{s}", .{margin});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try spacing.generateMargin(&generator, &parsed, margin);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "margin") != null);
    }
}

test "margin directional" {
    const allocator = testing.allocator;

    const directions = [_]struct { prefix: []const u8, prop: []const u8 }{
        .{ .prefix = "mt", .prop = "margin-top" },
        .{ .prefix = "mr", .prop = "margin-right" },
        .{ .prefix = "mb", .prop = "margin-bottom" },
        .{ .prefix = "ml", .prop = "margin-left" },
    };

    for (directions) |dir| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "{s}-4", .{dir.prefix});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try spacing.generateMargin(&generator, &parsed, "4");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, dir.prop) != null);
    }
}

test "margin axis" {
    const allocator = testing.allocator;

    const axes = [_]struct { prefix: []const u8, expected_props: []const []const u8 }{
        .{ .prefix = "mx", .expected_props = &[_][]const u8{ "margin-left", "margin-right" } },
        .{ .prefix = "my", .expected_props = &[_][]const u8{ "margin-top", "margin-bottom" } },
    };

    for (axes) |axis| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "{s}-4", .{axis.prefix});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try spacing.generateMargin(&generator, &parsed, "4");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "margin negative values" {
    const allocator = testing.allocator;

    const negative_margins = [_][]const u8{ "1", "2", "4", "8", "16" };

    for (negative_margins) |margin| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "-m-{s}", .{margin});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try spacing.generateMargin(&generator, &parsed, margin);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
        try testing.expect(std.mem.indexOf(u8, css, "margin") != null);
    }
}

// ============================================================================
// Padding Tests
// ============================================================================

test "padding all sides" {
    const allocator = testing.allocator;

    const paddings = [_][]const u8{
        "0",  "1",  "2",  "3",  "4",  "5",  "6",  "8",  "10",
        "12", "14", "16", "20", "24", "28", "32", "36", "40",
        "44", "48", "52", "56", "60", "64", "72", "80", "96",
    };

    for (paddings) |padding| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "p-{s}", .{padding});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try spacing.generatePadding(&generator, &parsed, padding);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "padding") != null);
    }
}

test "padding directional" {
    const allocator = testing.allocator;

    const directions = [_]struct { prefix: []const u8, prop: []const u8 }{
        .{ .prefix = "pt", .prop = "padding-top" },
        .{ .prefix = "pr", .prop = "padding-right" },
        .{ .prefix = "pb", .prop = "padding-bottom" },
        .{ .prefix = "pl", .prop = "padding-left" },
    };

    for (directions) |dir| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "{s}-4", .{dir.prefix});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try spacing.generatePadding(&generator, &parsed, "4");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, dir.prop) != null);
    }
}

test "padding axis" {
    const allocator = testing.allocator;

    const axes = [_]struct { prefix: []const u8 }{
        .{ .prefix = "px" },
        .{ .prefix = "py" },
    };

    for (axes) |axis| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "{s}-4", .{axis.prefix});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try spacing.generatePadding(&generator, &parsed, "4");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

// ============================================================================
// Space Between Tests
// ============================================================================

test "space between x" {
    const allocator = testing.allocator;

    const spaces = [_][]const u8{ "0", "1", "2", "4", "8", "16" };

    for (spaces) |space| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "space-x-{s}", .{space});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try spacing.generateSpaceBetween(&generator, &parsed, "x", space);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "space between y" {
    const allocator = testing.allocator;

    const spaces = [_][]const u8{ "0", "1", "2", "4", "8", "16" };

    for (spaces) |space| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "space-y-{s}", .{space});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try spacing.generateSpaceBetween(&generator, &parsed, "y", space);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "space between negative" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "-space-x-4");
    defer parsed.deinit(allocator);

    try spacing.generateSpaceBetween(&generator, &parsed, "x", "4");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
}

test "space between reverse" {
    const allocator = testing.allocator;

    const reverses = [_][]const u8{ "space-x-reverse", "space-y-reverse" };

    for (reverses) |reverse| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, reverse);
        defer parsed.deinit(allocator);

        const axis = if (std.mem.indexOf(u8, reverse, "x") != null) "x" else "y";
        try spacing.generateSpaceBetween(&generator, &parsed, axis, "reverse");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}
