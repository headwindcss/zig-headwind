const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const layout = headwind.layout;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

//============================================================================
// Display Tests
// ============================================================================

test "display values" {
    const allocator = testing.allocator;

    const displays = [_][]const u8{
        "block",        "inline-block", "inline",       "flex",
        "inline-flex",  "table",        "inline-table", "table-caption",
        "table-cell",   "table-column", "table-row",    "grid",
        "inline-grid",  "contents",     "list-item",    "hidden",
    };

    for (displays) |display| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, display);
        defer parsed.deinit(allocator);

        try layout.generateDisplay(&generator, &parsed, display);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
        try testing.expect(std.mem.indexOf(u8, css, "display") != null);
    }
}

// ============================================================================
// Position Tests
// ============================================================================

test "position values" {
    const allocator = testing.allocator;

    const positions = [_][]const u8{
        "static", "fixed", "absolute", "relative", "sticky",
    };

    for (positions) |position| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, position);
        defer parsed.deinit(allocator);

        try layout.generatePosition(&generator, &parsed, position);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "position") != null);
    }
}

// ============================================================================
// Inset Tests (Top/Right/Bottom/Left)
// ============================================================================

test "inset all sides" {
    const allocator = testing.allocator;

    const insets = [_][]const u8{ "0", "1", "2", "4", "auto" };

    for (insets) |inset| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "inset-{s}", .{inset});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try layout.generateInset(&generator, &parsed, inset);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "top/right/bottom/left values" {
    const allocator = testing.allocator;

    const directions = [_][]const u8{ "top", "right", "bottom", "left" };

    for (directions) |dir| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "{s}-4", .{dir});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try layout.generateInset(&generator, &parsed, "4");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, dir) != null);
    }
}

// ============================================================================
// Z-Index Tests
// ============================================================================

test "z-index values" {
    const allocator = testing.allocator;

    const z_indices = [_][]const u8{
        "0", "10", "20", "30", "40", "50", "auto",
    };

    for (z_indices) |z| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "z-{s}", .{z});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try layout.generateZIndex(&generator, &parsed, z);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "z-index") != null);
    }
}

// ============================================================================
// Overflow Tests
// ============================================================================

test "overflow values" {
    const allocator = testing.allocator;

    const overflows = [_][]const u8{
        "auto", "hidden", "clip", "visible", "scroll",
    };

    for (overflows) |overflow| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "overflow-{s}", .{overflow});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try layout.generateOverflow(&generator, &parsed, overflow);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "overflow") != null);
    }
}

test "overflow directional" {
    const allocator = testing.allocator;

    const directions = [_]struct { prefix: []const u8, prop: []const u8 }{
        .{ .prefix = "overflow-x", .prop = "overflow-x" },
        .{ .prefix = "overflow-y", .prop = "overflow-y" },
    };

    for (directions) |dir| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "{s}-auto", .{dir.prefix});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try layout.generateOverflow(&generator, &parsed, "auto");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, dir.prop) != null);
    }
}

// ============================================================================
// Visibility Tests
// ============================================================================

test "visibility values" {
    const allocator = testing.allocator;

    const visibilities = [_][]const u8{ "visible", "invisible", "collapse" };

    for (visibilities) |visibility| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, visibility);
        defer parsed.deinit(allocator);

        try layout.generateVisibility(&generator, &parsed, visibility);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "visibility") != null);
    }
}

// ============================================================================
// Object Fit Tests
// ============================================================================

test "object fit values" {
    const allocator = testing.allocator;

    const object_fits = [_][]const u8{
        "contain", "cover", "fill", "none", "scale-down",
    };

    for (object_fits) |fit| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "object-{s}", .{fit});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try layout.generateObjectFit(&generator, &parsed, fit);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "object-fit") != null);
    }
}

// ============================================================================
// Object Position Tests
// ============================================================================

test "object position values" {
    const allocator = testing.allocator;

    const positions = [_][]const u8{
        "bottom", "center", "left",        "left-bottom", "left-top",
        "right",  "right-bottom", "right-top", "top",
    };

    for (positions) |pos| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "object-{s}", .{pos});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try layout.generateObjectPosition(&generator, &parsed, pos);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "object-position") != null);
    }
}
