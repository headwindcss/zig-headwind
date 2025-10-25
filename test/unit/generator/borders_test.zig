const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const borders = headwind.borders;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Border Width Tests
// ============================================================================

test "border width default" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "border");
    defer parsed.deinit(allocator);

    try borders.generateBorderWidth(&generator, &parsed, "");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "border-width") != null);
}

test "border width values" {
    const allocator = testing.allocator;

    const widths = [_][]const u8{ "0", "2", "4", "8" };

    for (widths) |width| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "border-{s}", .{width});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try borders.generateBorderWidth(&generator, &parsed, width);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "border-width") != null);
    }
}

test "border width directional" {
    const allocator = testing.allocator;

    const directions = [_]struct { prefix: []const u8, prop: []const u8 }{
        .{ .prefix = "border-t", .prop = "border-top-width" },
        .{ .prefix = "border-r", .prop = "border-right-width" },
        .{ .prefix = "border-b", .prop = "border-bottom-width" },
        .{ .prefix = "border-l", .prop = "border-left-width" },
    };

    for (directions) |dir| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, dir.prefix);
        defer parsed.deinit(allocator);

        try borders.generateBorderWidth(&generator, &parsed, "");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, dir.prop) != null);
    }
}

// ============================================================================
// Border Color Tests
// ============================================================================

test "border color with OKLCH" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "border-blue-500");
    defer parsed.deinit(allocator);

    try borders.generateBorderColor(&generator, &parsed, "blue-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "border-color") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch(") != null);
}

test "border color directional" {
    const allocator = testing.allocator;

    const directions = [_]struct { prefix: []const u8, prop: []const u8 }{
        .{ .prefix = "border-t", .prop = "border-top-color" },
        .{ .prefix = "border-r", .prop = "border-right-color" },
        .{ .prefix = "border-b", .prop = "border-bottom-color" },
        .{ .prefix = "border-l", .prop = "border-left-color" },
    };

    for (directions) |dir| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "{s}-blue-500", .{dir.prefix});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try borders.generateBorderColor(&generator, &parsed, "blue-500");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, dir.prop) != null);
    }
}

// ============================================================================
// Border Style Tests
// ============================================================================

test "border style values" {
    const allocator = testing.allocator;

    const styles = [_][]const u8{
        "solid", "dashed", "dotted", "double", "hidden", "none",
    };

    for (styles) |style| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "border-{s}", .{style});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try borders.generateBorderStyle(&generator, &parsed, style);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "border-style") != null);
    }
}

// ============================================================================
// Border Radius Tests
// ============================================================================

test "border radius values" {
    const allocator = testing.allocator;

    const radii = [_][]const u8{
        "none", "sm", "md", "lg", "xl", "2xl", "3xl", "full",
    };

    for (radii) |radius| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "rounded-{s}", .{radius});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try borders.generateBorderRadius(&generator, &parsed, radius);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "border-radius") != null);
    }
}

test "border radius corners" {
    const allocator = testing.allocator;

    const corners = [_][]const u8{
        "rounded-tl", "rounded-tr", "rounded-br", "rounded-bl",
    };

    for (corners) |corner| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, corner);
        defer parsed.deinit(allocator);

        try borders.generateBorderRadius(&generator, &parsed, "");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

// ============================================================================
// Ring Tests
// ============================================================================

test "ring width values" {
    const allocator = testing.allocator;

    const widths = [_][]const u8{ "0", "1", "2", "4", "8" };

    for (widths) |width| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "ring-{s}", .{width});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try borders.generateRing(&generator, &parsed, width);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "ring color with OKLCH" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "ring-blue-500");
    defer parsed.deinit(allocator);

    try borders.generateRingColor(&generator, &parsed, "blue-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-ring-color") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch(") != null);
}

test "ring inset" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "ring-inset");
    defer parsed.deinit(allocator);

    try borders.generateRing(&generator, &parsed, "inset");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-ring-inset") != null);
}

// ============================================================================
// Outline Tests
// ============================================================================

test "outline width values" {
    const allocator = testing.allocator;

    const widths = [_][]const u8{ "0", "1", "2", "4", "8" };

    for (widths) |width| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "outline-{s}", .{width});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try borders.generateOutlineWidth(&generator, &parsed, width);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "outline-width") != null);
    }
}

test "outline color with OKLCH" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "outline-blue-500");
    defer parsed.deinit(allocator);

    try borders.generateOutlineColor(&generator, &parsed, "blue-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "outline-color") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch(") != null);
}

test "outline style values" {
    const allocator = testing.allocator;

    const styles = [_][]const u8{
        "solid", "dashed", "dotted", "double", "none",
    };

    for (styles) |style| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "outline-{s}", .{style});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try borders.generateOutlineStyle(&generator, &parsed, style);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "outline-style") != null);
    }
}

test "outline offset values" {
    const allocator = testing.allocator;

    const offsets = [_][]const u8{ "0", "1", "2", "4", "8" };

    for (offsets) |offset| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "outline-offset-{s}", .{offset});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try borders.generateOutlineOffset(&generator, &parsed, offset);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "outline-offset") != null);
    }
}
