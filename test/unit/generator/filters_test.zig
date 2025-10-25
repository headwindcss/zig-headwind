const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const filters = headwind.filters;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Blur Tests
// ============================================================================

test "blur values" {
    const allocator = testing.allocator;

    const blurs = [_][]const u8{
        "none", "sm", "md", "lg", "xl", "2xl", "3xl",
    };

    for (blurs) |blur| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "blur-{s}", .{blur});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try filters.generateBlur(&generator, &parsed, blur);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "--tw-blur") != null);
    }
}

test "blur default" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "blur");
    defer parsed.deinit(allocator);

    try filters.generateBlur(&generator, &parsed, "");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-blur") != null);
}

// ============================================================================
// Brightness Tests
// ============================================================================

test "brightness values" {
    const allocator = testing.allocator;

    const brightnesses = [_][]const u8{
        "0", "50", "75", "90", "95", "100", "105", "110", "125", "150", "200",
    };

    for (brightnesses) |brightness| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "brightness-{s}", .{brightness});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try filters.generateBrightness(&generator, &parsed, brightness);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "--tw-brightness") != null);
    }
}

// ============================================================================
// Contrast Tests
// ============================================================================

test "contrast values" {
    const allocator = testing.allocator;

    const contrasts = [_][]const u8{
        "0", "50", "75", "100", "125", "150", "200",
    };

    for (contrasts) |contrast| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "contrast-{s}", .{contrast});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try filters.generateContrast(&generator, &parsed, contrast);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "--tw-contrast") != null);
    }
}

// ============================================================================
// Grayscale Tests
// ============================================================================

test "grayscale values" {
    const allocator = testing.allocator;

    const grayscales = [_][]const u8{ "0", "50", "100" };

    for (grayscales) |grayscale| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "grayscale-{s}", .{grayscale});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try filters.generateGrayscale(&generator, &parsed, grayscale);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "--tw-grayscale") != null);
    }
}

test "grayscale default" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "grayscale");
    defer parsed.deinit(allocator);

    try filters.generateGrayscale(&generator, &parsed, "");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-grayscale") != null);
}

// ============================================================================
// Hue Rotate Tests
// ============================================================================

test "hue rotate values" {
    const allocator = testing.allocator;

    const hues = [_][]const u8{
        "0", "15", "30", "60", "90", "180",
    };

    for (hues) |hue| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "hue-rotate-{s}", .{hue});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try filters.generateHueRotate(&generator, &parsed, hue);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "--tw-hue-rotate") != null);
    }
}

test "hue rotate negative" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "-hue-rotate-60");
    defer parsed.deinit(allocator);

    try filters.generateHueRotate(&generator, &parsed, "60");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-hue-rotate") != null);
}

// ============================================================================
// Invert Tests
// ============================================================================

test "invert values" {
    const allocator = testing.allocator;

    const inverts = [_][]const u8{ "0", "50", "100" };

    for (inverts) |invert| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "invert-{s}", .{invert});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try filters.generateInvert(&generator, &parsed, invert);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "--tw-invert") != null);
    }
}

test "invert default" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "invert");
    defer parsed.deinit(allocator);

    try filters.generateInvert(&generator, &parsed, "");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-invert") != null);
}

// ============================================================================
// Saturate Tests
// ============================================================================

test "saturate values" {
    const allocator = testing.allocator;

    const saturates = [_][]const u8{
        "0", "50", "100", "150", "200",
    };

    for (saturates) |saturate| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "saturate-{s}", .{saturate});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try filters.generateSaturate(&generator, &parsed, saturate);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "--tw-saturate") != null);
    }
}

// ============================================================================
// Sepia Tests
// ============================================================================

test "sepia values" {
    const allocator = testing.allocator;

    const sepias = [_][]const u8{ "0", "50", "100" };

    for (sepias) |sepia| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "sepia-{s}", .{sepia});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try filters.generateSepia(&generator, &parsed, sepia);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "--tw-sepia") != null);
    }
}

test "sepia default" {
    const allocator = testing.allocator;
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "sepia");
    defer parsed.deinit(allocator);

    try filters.generateSepia(&generator, &parsed, "");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "--tw-sepia") != null);
}

// ============================================================================
// Backdrop Filter Tests
// ============================================================================

test "backdrop blur values" {
    const allocator = testing.allocator;

    const blurs = [_][]const u8{ "none", "sm", "md", "lg", "xl", "2xl", "3xl" };

    for (blurs) |blur| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "backdrop-blur-{s}", .{blur});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try filters.generateBackdropBlur(&generator, &parsed, blur);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "--tw-backdrop-blur") != null);
    }
}
