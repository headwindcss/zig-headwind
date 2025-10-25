const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const shadows = headwind.shadows;
const blend = headwind.blend;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Shadow Tests
// ============================================================================

test "box shadow values" {
    const allocator = testing.allocator;

    const shadow_sizes = [_][]const u8{
        "sm", "md", "lg", "xl", "2xl", "inner", "none",
    };

    for (shadow_sizes) |size| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "shadow-{s}", .{size});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try shadows.generateShadow(&generator, &parsed, size);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "box-shadow") != null);
    }
}

test "shadow default" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "shadow");
    defer parsed.deinit(allocator);

    try shadows.generateShadow(&generator, &parsed, "");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "box-shadow") != null);
}

test "shadow color with OKLCH" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "shadow-blue-500");
    defer parsed.deinit(allocator);

    try shadows.generateShadowColor(&generator, &parsed, "blue-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-shadow-color") != null);
}

// ============================================================================
// Opacity Tests
// ============================================================================

test "opacity values" {
    const allocator = testing.allocator;

    const opacities = [_][]const u8{
        "0",   "5",   "10",  "20",  "25",  "30",  "40",  "50",
        "60",  "70",  "75",  "80",  "90",  "95",  "100",
    };

    for (opacities) |opacity| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "opacity-{s}", .{opacity});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try shadows.generateOpacity(&generator, &parsed, opacity);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "opacity") != null);
    }
}

// ============================================================================
// Mix Blend Mode Tests
// ============================================================================

test "mix blend mode values" {
    const allocator = testing.allocator;

    const blend_modes = [_][]const u8{
        "normal",      "multiply",   "screen",     "overlay",    "darken",
        "lighten",     "color-dodge", "color-burn", "hard-light", "soft-light",
        "difference",  "exclusion",  "hue",        "saturation", "color",
        "luminosity",  "plus-lighter",
    };

    for (blend_modes) |mode| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "mix-blend-{s}", .{mode});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try blend.generateMixBlendMode(&generator, &parsed, mode);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "mix-blend-mode") != null);
    }
}

// ============================================================================
// Background Blend Mode Tests
// ============================================================================

test "background blend mode values" {
    const allocator = testing.allocator;

    const blend_modes = [_][]const u8{
        "normal",   "multiply", "screen",   "overlay",  "darken",
        "lighten",  "color-dodge", "color-burn", "hard-light", "soft-light",
        "difference", "exclusion", "hue",      "saturation", "color",
        "luminosity",
    };

    for (blend_modes) |mode| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "bg-blend-{s}", .{mode});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try blend.generateBgBlendMode(&generator, &parsed, mode);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "background-blend-mode") != null);
    }
}
