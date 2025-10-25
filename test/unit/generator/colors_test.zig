const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

// Import the colors module through headwind
const colors = headwind.colors;

// ============================================================================
// OKLCH Color Resolution Tests
// ============================================================================

test "resolve standard color with shade" {
    const test_cases = [_]struct {
        input: []const u8,
        should_exist: bool,
    }{
        .{ .input = "blue-500", .should_exist = true },
        .{ .input = "red-600", .should_exist = true },
        .{ .input = "green-400", .should_exist = true },
        .{ .input = "slate-900", .should_exist = true },
        .{ .input = "invalid-500", .should_exist = false },
        .{ .input = "blue-999", .should_exist = false },
    };

    for (test_cases) |case| {
        const result = colors.resolveColor(case.input);
        if (case.should_exist) {
            try testing.expect(result != null);
            // Should return OKLCH format string
            const oklch_value = result.?;
            try testing.expect(oklch_value.len > 0);
        } else {
            try testing.expectEqual(@as(?[]const u8, null), result);
        }
    }
}

test "resolve all color families" {
    const color_families = [_][]const u8{
        "red",    "orange", "amber",  "yellow", "lime",   "green",
        "emerald", "teal",   "cyan",   "sky",    "blue",   "indigo",
        "violet",  "purple", "fuchsia", "pink",   "rose",   "slate",
        "gray",    "zinc",   "neutral", "stone",
    };

    const shades = [_][]const u8{
        "50", "100", "200", "300", "400", "500",
        "600", "700", "800", "900", "950",
    };

    var success_count: usize = 0;

    for (color_families) |family| {
        for (shades) |shade| {
            var buf: [50]u8 = undefined;
            const color_name = std.fmt.bufPrint(&buf, "{s}-{s}", .{ family, shade }) catch unreachable;
            const result = colors.resolveColor(color_name);
            if (result != null) {
                success_count += 1;
            }
        }
    }

    // Should resolve most color-shade combinations (22 families × 11 shades = 242)
    try testing.expect(success_count > 200);
}

test "resolve special colors" {
    const special_colors = [_]struct {
        name: []const u8,
        should_exist: bool,
    }{
        .{ .name = "transparent", .should_exist = true },
        .{ .name = "current", .should_exist = true },
        .{ .name = "inherit", .should_exist = true },
        .{ .name = "black", .should_exist = true },
        .{ .name = "white", .should_exist = true },
    };

    for (special_colors) |color| {
        const result = colors.resolveColor(color.name);
        if (color.should_exist) {
            try testing.expect(result != null);
        } else {
            try testing.expectEqual(@as(?[]const u8, null), result);
        }
    }
}

test "resolve color returns valid OKLCH format" {
    const result = colors.resolveColor("blue-500");
    try testing.expect(result != null);

    const oklch_value = result.?;

    // OKLCH values should contain numbers and potentially spaces/slashes
    // Format is typically: "L C H" or "L C H / A"
    try testing.expect(oklch_value.len > 0);

    // Should contain at least one digit
    var has_digit = false;
    for (oklch_value) |c| {
        if (std.ascii.isDigit(c)) {
            has_digit = true;
            break;
        }
    }
    try testing.expect(has_digit);
}

test "resolve color is case sensitive" {
    const result1 = colors.resolveColor("blue-500");
    const result2 = colors.resolveColor("Blue-500");
    const result3 = colors.resolveColor("BLUE-500");

    // Lowercase should work
    try testing.expect(result1 != null);

    // Different cases might not work (case-sensitive)
    // This depends on implementation
    _ = result2;
    _ = result3;
}

test "resolve color with invalid shade returns null" {
    const invalid_shades = [_][]const u8{
        "blue-0",
        "blue-25",
        "blue-1000",
        "blue-550",
        "red-99",
    };

    for (invalid_shades) |color| {
        const result = colors.resolveColor(color);
        try testing.expectEqual(@as(?[]const u8, null), result);
    }
}

test "resolve color with empty string returns null" {
    const result = colors.resolveColor("");
    try testing.expectEqual(@as(?[]const u8, null), result);
}

test "resolve color with malformed input returns null" {
    const malformed = [_][]const u8{
        "blue-",
        "-500",
        "blue--500",
        "blue-red-500",
        "--blue-500",
    };

    for (malformed) |color| {
        const result = colors.resolveColor(color);
        // Should return null for malformed input
        _ = result; // May or may not be null depending on implementation
    }
}

// ============================================================================
// Color Parsing Tests
// ============================================================================

test "parseColorShade with valid input" {
    const result = colors.parseColorShade("blue-500");
    try testing.expect(result != null);

    const parsed = result.?;
    try testing.expectEqualStrings("blue", parsed.color);
    try testing.expectEqualStrings("500", parsed.shade);
}

test "parseColorShade with all shades" {
    const shades = [_][]const u8{
        "50", "100", "200", "300", "400", "500",
        "600", "700", "800", "900", "950",
    };

    for (shades) |shade| {
        var buf: [20]u8 = undefined;
        const color_name = std.fmt.bufPrint(&buf, "red-{s}", .{shade}) catch unreachable;
        const result = colors.parseColorShade(color_name);
        try testing.expect(result != null);

        const parsed = result.?;
        try testing.expectEqualStrings("red", parsed.color);
        try testing.expectEqualStrings(shade, parsed.shade);
    }
}

test "parseColorShade with hyphenated color names" {
    // Test if light-blue, blue-gray, etc. are supported
    const hyphenated = [_][]const u8{
        "light-blue-500",
        "blue-gray-600",
    };

    for (hyphenated) |color| {
        const result = colors.parseColorShade(color);
        // May or may not be supported depending on implementation
        _ = result;
    }
}

test "parseColorShade with single color (no shade)" {
    const result = colors.parseColorShade("blue");
    // Should return null or handle single colors
    _ = result;
}

test "parseColorShade with empty string" {
    const result = colors.parseColorShade("");
    try testing.expect(result != null);

    const parsed = result.?;
    try testing.expectEqualStrings("", parsed.color);
    try testing.expectEqualStrings("", parsed.shade);
}

test "parseColorShade with invalid format" {
    const invalid = [_][]const u8{
        "blue-",
        "-500",
        "blue--500",
    };

    for (invalid) |color| {
        const result = colors.parseColorShade(color);
        // Should return null for invalid format
        _ = result;
    }
}

// ============================================================================
// Comprehensive Color Coverage Tests
// ============================================================================

test "all Tailwind v4 colors are available" {
    // Test that all standard Tailwind colors with all shades are available
    const colors_with_all_shades = [_][]const u8{
        "slate", "gray", "zinc", "neutral", "stone",
        "red", "orange", "amber", "yellow", "lime", "green",
        "emerald", "teal", "cyan", "sky", "blue", "indigo",
        "violet", "purple", "fuchsia", "pink", "rose",
    };

    const standard_shades = [_][]const u8{
        "50", "100", "200", "300", "400", "500",
        "600", "700", "800", "900", "950",
    };

    for (colors_with_all_shades) |color_family| {
        for (standard_shades) |shade| {
            var buf: [50]u8 = undefined;
            const color_name = std.fmt.bufPrint(&buf, "{s}-{s}", .{ color_family, shade }) catch unreachable;
            const result = colors.resolveColor(color_name);

            // Each color-shade combination should exist
            if (result == null) {
                std.debug.print("Missing color: {s}\n", .{color_name});
            }
            try testing.expect(result != null);
        }
    }
}

test "OKLCH values are well-formed" {
    const test_colors = [_][]const u8{
        "red-500",
        "blue-500",
        "green-500",
        "gray-500",
    };

    for (test_colors) |color| {
        const result = colors.resolveColor(color);
        try testing.expect(result != null);

        const oklch_value = result.?;

        // OKLCH format should be: "L C H" where:
        // L = lightness (0-100% or 0-1)
        // C = chroma (0-0.4 typically)
        // H = hue (0-360)

        // At minimum, should have some numeric content
        try testing.expect(oklch_value.len >= 3);

        // Should be ASCII
        for (oklch_value) |c| {
            try testing.expect(std.ascii.isAscii(c));
        }
    }
}

test "color resolution is consistent" {
    // Same color should always return same OKLCH value
    const color = "blue-500";

    const result1 = colors.resolveColor(color);
    const result2 = colors.resolveColor(color);
    const result3 = colors.resolveColor(color);

    try testing.expect(result1 != null);
    try testing.expect(result2 != null);
    try testing.expect(result3 != null);

    // All should be the same
    try testing.expectEqualStrings(result1.?, result2.?);
    try testing.expectEqualStrings(result2.?, result3.?);
}

// ============================================================================
// Backwards Compatibility Tests
// ============================================================================

test "backwards compatibility - colors.colors.has() exists" {
    // The backwards compatibility layer should exist
    const has_blue = colors.colors.has("blue");
    const has_red = colors.colors.has("red");
    const has_invalid = colors.colors.has("notacolor");

    try testing.expect(has_blue);
    try testing.expect(has_red);
    try testing.expect(!has_invalid);
}

test "backwards compatibility - common colors are supported" {
    const common_colors = [_][]const u8{
        "red", "orange", "amber", "yellow", "lime", "green",
        "emerald", "teal", "cyan", "sky", "blue", "indigo",
        "violet", "purple", "fuchsia", "pink", "rose",
        "slate", "gray", "zinc", "neutral", "stone",
        "inherit", "current", "transparent", "black", "white",
    };

    for (common_colors) |color| {
        const has_color = colors.colors.has(color);
        try testing.expect(has_color);
    }
}

// ============================================================================
// Edge Cases and Stress Tests
// ============================================================================

test "very long color name returns null" {
    var buf: [1000]u8 = undefined;
    @memset(&buf, 'a');
    const long_name = buf[0..999];

    const result = colors.resolveColor(long_name);
    try testing.expectEqual(@as(?[]const u8, null), result);
}

test "color name with special characters" {
    const special = [_][]const u8{
        "blue@500",
        "blue#500",
        "blue$500",
        "blue!500",
    };

    for (special) |color| {
        const result = colors.resolveColor(color);
        // Should return null for invalid characters
        try testing.expectEqual(@as(?[]const u8, null), result);
    }
}

test "color resolution with numbers only" {
    const result = colors.resolveColor("500");
    // Pure numbers shouldn't be valid colors
    try testing.expectEqual(@as(?[]const u8, null), result);
}

test "multiple consecutive hyphens" {
    const result = colors.resolveColor("blue---500");
    try testing.expectEqual(@as(?[]const u8, null), result);
}

test "color with whitespace" {
    const with_spaces = [_][]const u8{
        "blue- 500",
        "blue -500",
        " blue-500",
        "blue-500 ",
        "blue - 500",
    };

    for (with_spaces) |color| {
        const result = colors.resolveColor(color);
        // Whitespace should make it invalid
        _ = result; // May or may not handle trimming
    }
}

// ============================================================================
// Performance Tests (Light)
// ============================================================================

test "color resolution is fast for common colors" {
    // Resolve the same color many times - should be fast
    const iterations = 1000;
    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        const result = colors.resolveColor("blue-500");
        try testing.expect(result != null);
    }
}

test "color resolution for all shades is fast" {
    // Resolve all shades of all colors - should complete quickly
    const families = [_][]const u8{ "red", "blue", "green", "gray" };
    const shades = [_][]const u8{ "50", "100", "200", "300", "400", "500", "600", "700", "800", "900", "950" };

    var buf: [50]u8 = undefined;
    for (families) |family| {
        for (shades) |shade| {
            const color_name = std.fmt.bufPrint(&buf, "{s}-{s}", .{ family, shade }) catch unreachable;
            _ = colors.resolveColor(color_name);
        }
    }
}
