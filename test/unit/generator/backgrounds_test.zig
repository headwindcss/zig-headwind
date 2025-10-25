const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const backgrounds = headwind.backgrounds;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Background Color Tests
// ============================================================================

test "background color with OKLCH" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "bg-blue-500");
    defer parsed.deinit(allocator);

    try backgrounds.generateBgColor(&generator, &parsed, "blue-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "background-color") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch(") != null);
}

test "background color with arbitrary value" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "bg-[#ff0000]");
    defer parsed.deinit(allocator);

    try backgrounds.generateBgColor(&generator, &parsed, "#ff0000");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "background-color: #ff0000") != null);
}

test "background special colors" {
    const allocator = testing.allocator;

    const special_colors = [_][]const u8{
        "transparent",
        "current",
        "inherit",
        "black",
        "white",
    };

    for (special_colors) |color| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "bg-{s}", .{color});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try backgrounds.generateBgColor(&generator, &parsed, color);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
        try testing.expect(std.mem.indexOf(u8, css, "background-color") != null);
    }
}

// ============================================================================
// Background Attachment Tests
// ============================================================================

test "background attachment values" {
    const allocator = testing.allocator;

    const attachments = [_][]const u8{
        "fixed",
        "local",
        "scroll",
    };

    for (attachments) |attachment| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "bg-{s}", .{attachment});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try backgrounds.generateBgAttachment(&generator, &parsed, attachment);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "background-attachment") != null);
        try testing.expect(std.mem.indexOf(u8, css, attachment) != null);
    }
}

// ============================================================================
// Background Clip Tests
// ============================================================================

test "background clip values" {
    const allocator = testing.allocator;

    const clips = [_]struct { input: []const u8, expected: []const u8 }{
        .{ .input = "border", .expected = "border-box" },
        .{ .input = "padding", .expected = "padding-box" },
        .{ .input = "content", .expected = "content-box" },
        .{ .input = "text", .expected = "text" },
    };

    for (clips) |clip| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "bg-clip-{s}", .{clip.input});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try backgrounds.generateBgClip(&generator, &parsed, clip.input);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "background-clip") != null);
        try testing.expect(std.mem.indexOf(u8, css, clip.expected) != null);
    }
}

// ============================================================================
// Background Origin Tests
// ============================================================================

test "background origin values" {
    const allocator = testing.allocator;

    const origins = [_]struct { input: []const u8, expected: []const u8 }{
        .{ .input = "border", .expected = "border-box" },
        .{ .input = "padding", .expected = "padding-box" },
        .{ .input = "content", .expected = "content-box" },
    };

    for (origins) |origin| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "bg-origin-{s}", .{origin.input});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try backgrounds.generateBgOrigin(&generator, &parsed, origin.input);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "background-origin") != null);
        try testing.expect(std.mem.indexOf(u8, css, origin.expected) != null);
    }
}

// ============================================================================
// Background Position Tests
// ============================================================================

test "background position values" {
    const allocator = testing.allocator;

    const positions = [_]struct { input: []const u8, expected: []const u8 }{
        .{ .input = "bottom", .expected = "bottom" },
        .{ .input = "center", .expected = "center" },
        .{ .input = "left", .expected = "left" },
        .{ .input = "left-bottom", .expected = "left bottom" },
        .{ .input = "left-top", .expected = "left top" },
        .{ .input = "right", .expected = "right" },
        .{ .input = "right-bottom", .expected = "right bottom" },
        .{ .input = "right-top", .expected = "right top" },
        .{ .input = "top", .expected = "top" },
    };

    for (positions) |position| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "bg-{s}", .{position.input});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try backgrounds.generateBgPosition(&generator, &parsed, position.input);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "background-position") != null);
        try testing.expect(std.mem.indexOf(u8, css, position.expected) != null);
    }
}

// ============================================================================
// Background Repeat Tests
// ============================================================================

test "background repeat values" {
    const allocator = testing.allocator;

    const repeats = [_]struct { input: []const u8, expected: []const u8 }{
        .{ .input = "repeat", .expected = "repeat" },
        .{ .input = "no-repeat", .expected = "no-repeat" },
        .{ .input = "repeat-x", .expected = "repeat-x" },
        .{ .input = "repeat-y", .expected = "repeat-y" },
        .{ .input = "repeat-round", .expected = "round" },
        .{ .input = "repeat-space", .expected = "space" },
    };

    for (repeats) |repeat| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "bg-{s}", .{repeat.input});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try backgrounds.generateBgRepeat(&generator, &parsed, repeat.input);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "background-repeat") != null);
        try testing.expect(std.mem.indexOf(u8, css, repeat.expected) != null);
    }
}

// ============================================================================
// Background Size Tests
// ============================================================================

test "background size values" {
    const allocator = testing.allocator;

    const sizes = [_][]const u8{
        "auto",
        "cover",
        "contain",
    };

    for (sizes) |size| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "bg-{s}", .{size});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try backgrounds.generateBgSize(&generator, &parsed, size);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "background-size") != null);
        try testing.expect(std.mem.indexOf(u8, css, size) != null);
    }
}

// ============================================================================
// Background Image Tests
// ============================================================================

test "background none" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "bg-none");
    defer parsed.deinit(allocator);

    try backgrounds.generateBgNone(&generator, &parsed);

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "background-image: none") != null);
}

// ============================================================================
// Gradient Tests
// ============================================================================

test "gradient directions" {
    const allocator = testing.allocator;

    const directions = [_][]const u8{
        "to-t",
        "to-tr",
        "to-r",
        "to-br",
        "to-b",
        "to-bl",
        "to-l",
        "to-tl",
    };

    for (directions) |direction| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "bg-gradient-{s}", .{direction});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try backgrounds.generateBgGradient(&generator, &parsed, direction);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "background-image") != null);
        try testing.expect(std.mem.indexOf(u8, css, "linear-gradient") != null);
        try testing.expect(std.mem.indexOf(u8, css, "--tw-gradient-stops") != null);
    }
}

test "gradient from color" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "from-blue-500");
    defer parsed.deinit(allocator);

    try backgrounds.generateGradientFrom(&generator, &parsed, "blue-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-gradient-from") != null);
    try testing.expect(std.mem.indexOf(u8, css, "--tw-gradient-stops") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch(") != null);
}

test "gradient via color" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "via-purple-500");
    defer parsed.deinit(allocator);

    try backgrounds.generateGradientVia(&generator, &parsed, "purple-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-gradient-via") != null);
    try testing.expect(std.mem.indexOf(u8, css, "--tw-gradient-stops") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch(") != null);
}

test "gradient to color" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "to-red-500");
    defer parsed.deinit(allocator);

    try backgrounds.generateGradientTo(&generator, &parsed, "red-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-gradient-to") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch(") != null);
}

test "gradient color stop positions" {
    const allocator = testing.allocator;

    const positions = [_]struct { fn_name: []const u8, generate_fn: *const fn (*CSSGenerator, *const class_parser.ParsedClass, []const u8) anyerror!void, var_name: []const u8 }{
        .{ .fn_name = "from", .generate_fn = backgrounds.generateGradientFromPosition, .var_name = "--tw-gradient-from-position" },
        .{ .fn_name = "via", .generate_fn = backgrounds.generateGradientViaPosition, .var_name = "--tw-gradient-via-position" },
        .{ .fn_name = "to", .generate_fn = backgrounds.generateGradientToPosition, .var_name = "--tw-gradient-to-position" },
    };

    for (positions) |pos| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "{s}-50", .{pos.fn_name});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try pos.generate_fn(&generator, &parsed, "50");

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, pos.var_name) != null);
        try testing.expect(std.mem.indexOf(u8, css, "50%") != null);
    }
}
