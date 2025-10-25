const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const sizing = headwind.sizing;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Width Tests
// ============================================================================

test "width with spacing scale values" {
    const allocator = testing.allocator;

    const widths = [_][]const u8{
        "0",   "1",  "2",  "3",   "4",   "5",   "6",   "7",   "8",
        "9",   "10", "11", "12",  "14",  "16",  "20",  "24",  "28",
        "32",  "36", "40", "44",  "48",  "52",  "56",  "60",  "64",
        "72",  "80", "96", "auto"
    };

    for (widths) |width| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "w-{s}", .{width});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try sizing.generateWidth(&generator, &parsed, width);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
        try testing.expect(std.mem.indexOf(u8, css, "width") != null);
    }
}

test "width with fractional values" {
    const allocator = testing.allocator;

    const fractions = [_][]const u8{
        "1/2",  "1/3",  "2/3",  "1/4", "2/4",  "3/4",
        "1/5",  "2/5",  "3/5",  "4/5", "1/6",  "2/6",
        "3/6",  "4/6",  "5/6",  "1/12", "2/12", "3/12",
        "4/12", "5/12", "6/12", "7/12", "8/12", "9/12",
        "10/12", "11/12", "full"
    };

    for (fractions) |fraction| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "w-{s}", .{fraction});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try sizing.generateWidth(&generator, &parsed, fraction);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "width with viewport values" {
    const allocator = testing.allocator;

    const viewport_values = [_][]const u8{
        "screen", "min", "max", "fit",
    };

    for (viewport_values) |value| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "w-{s}", .{value});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try sizing.generateWidth(&generator, &parsed, value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "width with arbitrary value" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "w-[200px]");
    defer parsed.deinit(allocator);

    try sizing.generateWidth(&generator, &parsed, "200px");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "width") != null);
}

// ============================================================================
// Min/Max Width Tests
// ============================================================================

test "min-width values" {
    const allocator = testing.allocator;

    const min_widths = [_][]const u8{ "0", "full", "min", "max", "fit" };

    for (min_widths) |value| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "min-w-{s}", .{value});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try sizing.generateMinWidth(&generator, &parsed, value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "min-width") != null);
    }
}

test "max-width values" {
    const allocator = testing.allocator;

    const max_widths = [_][]const u8{
        "0",    "xs",   "sm",   "md",   "lg",   "xl",   "2xl",
        "3xl",  "4xl",  "5xl",  "6xl",  "7xl",  "full", "min",
        "max",  "fit",  "prose", "screen-sm", "screen-md", "screen-lg",
        "screen-xl", "screen-2xl",
    };

    for (max_widths) |value| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "max-w-{s}", .{value});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try sizing.generateMaxWidth(&generator, &parsed, value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

// ============================================================================
// Height Tests
// ============================================================================

test "height with spacing scale values" {
    const allocator = testing.allocator;

    const heights = [_][]const u8{
        "0", "1",  "2", "3",  "4",  "5",  "6",  "7",  "8",
        "9", "10", "11", "12", "14", "16", "20", "24", "auto",
    };

    for (heights) |height| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "h-{s}", .{height});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try sizing.generateHeight(&generator, &parsed, height);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "height") != null);
    }
}

test "height with fractional values" {
    const allocator = testing.allocator;

    const fractions = [_][]const u8{
        "1/2", "1/3", "2/3", "1/4", "2/4", "3/4", "1/5", "2/5", "3/5",
        "4/5", "1/6", "2/6", "3/6", "4/6", "5/6", "full",
    };

    for (fractions) |fraction| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "h-{s}", .{fraction});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try sizing.generateHeight(&generator, &parsed, fraction);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "height with viewport values" {
    const allocator = testing.allocator;

    const viewport_values = [_][]const u8{ "screen", "min", "max", "fit" };

    for (viewport_values) |value| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "h-{s}", .{value});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try sizing.generateHeight(&generator, &parsed, value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

// ============================================================================
// Min/Max Height Tests
// ============================================================================

test "min-height values" {
    const allocator = testing.allocator;

    const min_heights = [_][]const u8{ "0", "full", "screen", "min", "max", "fit" };

    for (min_heights) |value| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "min-h-{s}", .{value});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try sizing.generateMinHeight(&generator, &parsed, value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "min-height") != null);
    }
}

test "max-height values" {
    const allocator = testing.allocator;

    const max_heights = [_][]const u8{ "0", "full", "screen", "min", "max", "fit" };

    for (max_heights) |value| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "max-h-{s}", .{value});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try sizing.generateMaxHeight(&generator, &parsed, value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}
