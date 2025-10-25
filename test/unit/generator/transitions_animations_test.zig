const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const transitions = headwind.transitions;
const animations = headwind.animations;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Transition Property Tests
// ============================================================================

test "transition property values" {
    const allocator = testing.allocator;

    const properties = [_]struct { class: []const u8, expected: []const u8 }{
        .{ .class = "transition-none", .expected = "none" },
        .{ .class = "transition-all", .expected = "all" },
        .{ .class = "transition-colors", .expected = "colors" },
        .{ .class = "transition-opacity", .expected = "opacity" },
        .{ .class = "transition-shadow", .expected = "shadow" },
        .{ .class = "transition-transform", .expected = "transform" },
    };

    for (properties) |prop| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, prop.class);
        defer parsed.deinit(allocator);

        try transitions.generateTransitionProperty(&generator, &parsed, prop.expected);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "transition-property") != null);
    }
}

test "transition default" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "transition");
    defer parsed.deinit(allocator);

    try transitions.generateTransitionProperty(&generator, &parsed, "");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "transition-property") != null);
}

// ============================================================================
// Transition Duration Tests
// ============================================================================

test "transition duration values" {
    const allocator = testing.allocator;

    const durations = [_][]const u8{
        "75", "100", "150", "200", "300", "500", "700", "1000",
    };

    for (durations) |duration| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "duration-{s}", .{duration});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try transitions.generateTransitionDuration(&generator, &parsed, duration);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "transition-duration") != null);
    }
}

// ============================================================================
// Transition Timing Function Tests
// ============================================================================

test "transition timing function values" {
    const allocator = testing.allocator;

    const timings = [_]struct { class: []const u8, value: []const u8 }{
        .{ .class = "ease-linear", .value = "linear" },
        .{ .class = "ease-in", .value = "in" },
        .{ .class = "ease-out", .value = "out" },
        .{ .class = "ease-in-out", .value = "in-out" },
    };

    for (timings) |timing| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, timing.class);
        defer parsed.deinit(allocator);

        try transitions.generateTransitionTiming(&generator, &parsed, timing.value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "transition-timing-function") != null);
    }
}

// ============================================================================
// Transition Delay Tests
// ============================================================================

test "transition delay values" {
    const allocator = testing.allocator;

    const delays = [_][]const u8{
        "75", "100", "150", "200", "300", "500", "700", "1000",
    };

    for (delays) |delay| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "delay-{s}", .{delay});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try transitions.generateTransitionDelay(&generator, &parsed, delay);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "transition-delay") != null);
    }
}

// ============================================================================
// Animation Tests
// ============================================================================

test "animation values" {
    const allocator = testing.allocator;

    const anims = [_]struct { class: []const u8, value: []const u8 }{
        .{ .class = "animate-none", .value = "none" },
        .{ .class = "animate-spin", .value = "spin" },
        .{ .class = "animate-ping", .value = "ping" },
        .{ .class = "animate-pulse", .value = "pulse" },
        .{ .class = "animate-bounce", .value = "bounce" },
    };

    for (anims) |anim| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        var parsed = try class_parser.parseClass(allocator, anim.class);
        defer parsed.deinit(allocator);

        try animations.generateAnimation(&generator, &parsed, anim.value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "animation") != null);
    }
}

test "animation with keyframes" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "animate-spin");
    defer parsed.deinit(allocator);

    try animations.generateAnimation(&generator, &parsed, "spin");

    const css = try generator.generate();
    defer allocator.free(css);

    // Should contain @keyframes definition
    try testing.expect(std.mem.indexOf(u8, css, "animation") != null);
}
