const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const transforms = headwind.transforms;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Scale Tests
// ============================================================================

test "scale values" {
    const allocator = testing.allocator;

    const scales = [_][]const u8{
        "0", "50", "75", "90", "95", "100", "105", "110", "125", "150",
    };

    for (scales) |scale| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "scale-{s}", .{scale});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try transforms.generateScale(&generator, &parsed, scale);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "--tw-scale") != null);
    }
}

test "scale directional" {
    const allocator = testing.allocator;

    const directions = [_]struct { prefix: []const u8, var_name: []const u8 }{
        .{ .prefix = "scale-x", .var_name = "--tw-scale-x" },
        .{ .prefix = "scale-y", .var_name = "--tw-scale-y" },
    };

    for (directions) |dir| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "{s}-100", .{dir.prefix});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try transforms.generateScale(&generator, &parsed, "100");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, dir.var_name) != null);
    }
}

// ============================================================================
// Rotate Tests
// ============================================================================

test "rotate values" {
    const allocator = testing.allocator;

    const rotates = [_][]const u8{
        "0", "1", "2", "3", "6", "12", "45", "90", "180",
    };

    for (rotates) |rotate| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "rotate-{s}", .{rotate});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try transforms.generateRotate(&generator, &parsed, rotate);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "--tw-rotate") != null);
    }
}

test "rotate negative" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "-rotate-45");
    defer parsed.deinit(allocator);

    try transforms.generateRotate(&generator, &parsed, "45");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-rotate") != null);
}

// ============================================================================
// Translate Tests
// ============================================================================

test "translate values" {
    const allocator = testing.allocator;

    const translates = [_][]const u8{
        "0", "1", "2", "4", "8", "16", "32",
    };

    const directions = [_]struct { prefix: []const u8, var_name: []const u8 }{
        .{ .prefix = "translate-x", .var_name = "--tw-translate-x" },
        .{ .prefix = "translate-y", .var_name = "--tw-translate-y" },
    };

    for (directions) |dir| {
        for (translates) |translate| {
            var generator = CSSGenerator.init(allocator);
            defer generator.deinit();

            const class_name = try std.fmt.allocPrint(allocator, "{s}-{s}", .{ dir.prefix, translate });
            defer allocator.free(class_name);

            var parsed = try class_parser.parseClass(allocator, class_name);
            defer parsed.deinit(allocator);

            try transforms.generateTranslate(&generator, &parsed, translate);

            const css = try generator.generate();
            defer allocator.free(css);

            try testing.expect(std.mem.indexOf(u8, css, dir.var_name) != null);
        }
    }
}

test "translate negative" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "-translate-x-4");
    defer parsed.deinit(allocator);

    try transforms.generateTranslate(&generator, &parsed, "4");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-translate-x") != null);
}

// ============================================================================
// Skew Tests
// ============================================================================

test "skew values" {
    const allocator = testing.allocator;

    const skews = [_][]const u8{ "0", "1", "2", "3", "6", "12" };

    const directions = [_]struct { prefix: []const u8, var_name: []const u8 }{
        .{ .prefix = "skew-x", .var_name = "--tw-skew-x" },
        .{ .prefix = "skew-y", .var_name = "--tw-skew-y" },
    };

    for (directions) |dir| {
        for (skews) |skew| {
            var generator = CSSGenerator.init(allocator);
            defer generator.deinit();

            const class_name = try std.fmt.allocPrint(allocator, "{s}-{s}", .{ dir.prefix, skew });
            defer allocator.free(class_name);

            var parsed = try class_parser.parseClass(allocator, class_name);
            defer parsed.deinit(allocator);

            try transforms.generateSkew(&generator, &parsed, skew);

            const css = try generator.generate();
            defer allocator.free(css);

            try testing.expect(std.mem.indexOf(u8, css, dir.var_name) != null);
        }
    }
}

// ============================================================================
// Transform Origin Tests
// ============================================================================

test "transform origin values" {
    const allocator = testing.allocator;

    const origins = [_][]const u8{
        "center",       "top",          "top-right",    "right",
        "bottom-right", "bottom",       "bottom-left",  "left",
        "top-left",
    };

    for (origins) |origin| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "origin-{s}", .{origin});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try transforms.generateTransformOrigin(&generator, &parsed, origin);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "transform-origin") != null);
    }
}
