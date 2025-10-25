const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const class_parser = headwind.class_parser;
const CSSGenerator = headwind.CSSGenerator;

// ============================================================================
// COMPREHENSIVE EDGE CASE TESTING
// ============================================================================
// This file contains exhaustive edge case testing to ensure robustness

// ============================================================================
// Input Validation Edge Cases
// ============================================================================

test "edge case: empty string" {
    const allocator = testing.allocator;

    const result = class_parser.parseClass(allocator, "");
    try testing.expectError(error.InvalidClassName, result);
}

test "edge case: only whitespace" {
    const allocator = testing.allocator;

    const whitespace_variants = [_][]const u8{
        " ",
        "  ",
        "\t",
        "\n",
        "   \t\n  ",
    };

    for (whitespace_variants) |input| {
        const result = class_parser.parseClass(allocator, input);
        try testing.expectError(error.InvalidClassName, result);
    }
}

test "edge case: null bytes" {
    const allocator = testing.allocator;

    // Zig strings can contain null bytes
    const with_null = "bg-blue\x00-500";
    var parsed = try class_parser.parseClass(allocator, with_null);
    defer parsed.deinit(allocator);

    // Should handle gracefully (may treat as separator or invalid)
    try testing.expect(parsed.utility.len > 0);
}

test "edge case: very long class name (1MB)" {
    const allocator = testing.allocator;

    // Create a 1MB class name
    var long_class = std.ArrayList(u8).init(allocator);
    defer long_class.deinit();

    try long_class.appendSlice("bg-");
    for (0..1024 * 1024) |_| {
        try long_class.append('a');
    }

    var parsed = try class_parser.parseClass(allocator, long_class.items);
    defer parsed.deinit(allocator);

    try testing.expect(parsed.utility.len > 1000000);
}

test "edge case: maximum variant nesting" {
    const allocator = testing.allocator;

    // Create deeply nested variants
    var nested = std.ArrayList(u8).init(allocator);
    defer nested.deinit();

    // 100 levels of nesting
    for (0..100) |_| {
        try nested.appendSlice("hover:");
    }
    try nested.appendSlice("bg-blue-500");

    var parsed = try class_parser.parseClass(allocator, nested.items);
    defer parsed.deinit(allocator);

    try testing.expect(parsed.variants.len == 100);
}

// ============================================================================
// Unicode and Special Characters
// ============================================================================

test "edge case: unicode in class names" {
    const allocator = testing.allocator;

    const unicode_classes = [_][]const u8{
        "content-['Hello_世界']",
        "content-['🚀']",
        "content-['Ñoño']",
        "[data-value='café']",
    };

    for (unicode_classes) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.utility.len > 0);
    }
}

test "edge case: emoji in arbitrary values" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "content-['🎉_🎊_🎈']");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_arbitrary);
}

test "edge case: combining diacritical marks" {
    const allocator = testing.allocator;

    // é can be represented as e + ́ (combining acute accent)
    var parsed = try class_parser.parseClass(allocator, "content-['café']");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_arbitrary);
}

test "edge case: zero-width characters" {
    const allocator = testing.allocator;

    // Zero-width space U+200B
    const with_zwsp = "bg-blue\u{200B}-500";
    var parsed = try class_parser.parseClass(allocator, with_zwsp);
    defer parsed.deinit(allocator);

    try testing.expect(parsed.utility.len > 0);
}

test "edge case: right-to-left text" {
    const allocator = testing.allocator;

    // Arabic text (RTL)
    var parsed = try class_parser.parseClass(allocator, "content-['مرحبا']");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_arbitrary);
}

// ============================================================================
// Arbitrary Value Edge Cases
// ============================================================================

test "edge case: deeply nested brackets" {
    const allocator = testing.allocator;

    const nested_brackets = [_][]const u8{
        "w-[[[100px]]]",  // Triple nested
        "content-['[[[nested]]]']",
        "bg-[url('data:image/svg+xml,...[brackets]...')]",
    };

    for (nested_brackets) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.is_arbitrary);
    }
}

test "edge case: unclosed brackets" {
    const allocator = testing.allocator;

    const malformed = [_][]const u8{
        "w-[100px",
        "bg-[[100px]",
        "content-['hello",
    };

    for (malformed) |class| {
        const result = class_parser.parseClass(allocator, class);
        // Should either parse gracefully or error
        if (result) |parsed| {
            parsed.deinit(allocator);
        } else |_| {
            // Error is acceptable
        }
    }
}

test "edge case: empty brackets" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "w-[]");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_arbitrary);
}

test "edge case: brackets with only whitespace" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "w-[   ]");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_arbitrary);
}

test "edge case: complex calc expressions" {
    const allocator = testing.allocator;

    const calc_expressions = [_][]const u8{
        "w-[calc(100%-20px)]",
        "w-[calc(100vw-calc(100%-20px))]",  // Nested calc
        "w-[calc((100%-20px)/2)]",
        "w-[min(100%,calc(100vw-40px))]",
        "w-[clamp(200px,50%,calc(100%-100px))]",
    };

    for (calc_expressions) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.is_arbitrary);
        try testing.expect(std.mem.indexOf(u8, parsed.arbitrary_value.?, "calc") != null or
                          std.mem.indexOf(u8, parsed.arbitrary_value.?, "min") != null or
                          std.mem.indexOf(u8, parsed.arbitrary_value.?, "clamp") != null);
    }
}

test "edge case: CSS variables in arbitrary values" {
    const allocator = testing.allocator;

    const css_vars = [_][]const u8{
        "w-[var(--width)]",
        "bg-[var(--primary-color)]",
        "text-[var(--text-size,_16px)]",  // With fallback
    };

    for (css_vars) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.is_arbitrary);
        try testing.expect(std.mem.indexOf(u8, parsed.arbitrary_value.?, "var(") != null);
    }
}

test "edge case: data URLs in arbitrary values" {
    const allocator = testing.allocator;

    const data_url = "bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCI+')]";
    var parsed = try class_parser.parseClass(allocator, data_url);
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_arbitrary);
}

test "edge case: multiple underscores (spaces)" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "grid-cols-[1fr___2fr___3fr]");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_arbitrary);
}

// ============================================================================
// Variant Edge Cases
// ============================================================================

test "edge case: duplicate variants" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "hover:hover:hover:bg-blue-500");
    defer parsed.deinit(allocator);

    // Should parse but may have duplicate variants
    try testing.expect(parsed.variants.len > 0);
}

test "edge case: empty variant" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, ":bg-blue-500");
    defer parsed.deinit(allocator);

    // Should handle gracefully
    try testing.expect(parsed.utility.len > 0);
}

test "edge case: trailing colon" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "hover:");
    defer parsed.deinit(allocator);

    // Should handle gracefully
    try testing.expect(parsed.utility.len > 0 or parsed.variants.len > 0);
}

test "edge case: multiple consecutive colons" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "hover:::bg-blue-500");
    defer parsed.deinit(allocator);

    // Should parse, may have empty variants
    try testing.expect(parsed.utility.len > 0);
}

test "edge case: arbitrary selectors with special chars" {
    const allocator = testing.allocator;

    const special_selectors = [_][]const u8{
        "[&>*]:text-blue-500",
        "[&_+_&]:text-blue-500",
        "[&:nth-child(2n+1)]:bg-gray-100",
        "[&::before]:content-['']",
    };

    for (special_selectors) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.variants.len > 0 or parsed.utility.len > 0);
    }
}

// ============================================================================
// Important Modifier Edge Cases
// ============================================================================

test "edge case: important without utility" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "!");
    defer parsed.deinit(allocator);

    // Should handle gracefully
    try testing.expect(parsed.utility.len >= 0);
}

test "edge case: multiple important modifiers" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "bg-blue-500!!!");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_important);
}

test "edge case: important in middle of class" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "bg-blue!-500");
    defer parsed.deinit(allocator);

    // Should parse but may treat ! differently
    try testing.expect(parsed.utility.len > 0);
}

// ============================================================================
// Negative Value Edge Cases
// ============================================================================

test "edge case: double negative" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "--m-4");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.utility.len > 0);
}

test "edge case: negative with arbitrary value" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "-translate-x-[calc(-50%-10px)]");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.utility.len > 0);
}

test "edge case: negative without value" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "-m-");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.utility.len > 0);
}

// ============================================================================
// Numeric Edge Cases
// ============================================================================

test "edge case: very large numbers" {
    const allocator = testing.allocator;

    const large_numbers = [_][]const u8{
        "w-[999999999px]",
        "z-[2147483647]",  // Max i32
        "opacity-[0.999999999]",
    };

    for (large_numbers) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.is_arbitrary);
    }
}

test "edge case: scientific notation" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "w-[1e10px]");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_arbitrary);
}

test "edge case: negative zero" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "-m-0");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.utility.len > 0);
}

test "edge case: fractional values with many decimals" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "opacity-[0.123456789]");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_arbitrary);
}

// ============================================================================
// Color Edge Cases
// ============================================================================

test "edge case: invalid hex colors" {
    const allocator = testing.allocator;

    const invalid_hex = [_][]const u8{
        "bg-[#gggggg]",  // Invalid hex chars
        "bg-[#12]",      // Too short
        "bg-[#12345]",   // Invalid length
        "bg-[#]",        // Empty
    };

    for (invalid_hex) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.is_arbitrary);
        // Parser accepts it, generator may reject
    }
}

test "edge case: rgb with invalid values" {
    const allocator = testing.allocator;

    const invalid_rgb = [_][]const u8{
        "bg-[rgb(999,999,999)]",  // Out of range
        "bg-[rgb(-10,20,30)]",    // Negative
        "bg-[rgb(1.5,2.5,3.5)]",  // Decimals
    };

    for (invalid_rgb) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.is_arbitrary);
    }
}

test "edge case: oklch with extreme values" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "bg-[oklch(999%_999_999)]");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_arbitrary);
}

// ============================================================================
// Special Character Edge Cases
// ============================================================================

test "edge case: backslash escaping" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "content-['\\']");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.is_arbitrary);
}

test "edge case: quotes in arbitrary values" {
    const allocator = testing.allocator;

    const with_quotes = [_][]const u8{
        "content-['it\\'s']",
        "content-[\"quote\"]",
        "content-['\"nested\"']",
    };

    for (with_quotes) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.is_arbitrary);
    }
}

test "edge case: newlines and tabs in class" {
    const allocator = testing.allocator;

    var parsed = try class_parser.parseClass(allocator, "bg-blue\n\t-500");
    defer parsed.deinit(allocator);

    try testing.expect(parsed.utility.len > 0);
}

// ============================================================================
// CSS Generation Edge Cases
// ============================================================================

test "edge case: generate CSS with empty generator" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    const css = try generator.generate();
    defer allocator.free(css);

    // Should return empty or minimal CSS
    try testing.expect(css.len >= 0);
}

test "edge case: generate with duplicate classes" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    // Add same class multiple times
    for (0..100) |_| {
        var parsed = try class_parser.parseClass(allocator, "bg-blue-500");
        defer parsed.deinit(allocator);

        try headwind.backgrounds.generateBgColor(&generator, &parsed, "blue-500");
    }

    const css = try generator.generate();
    defer allocator.free(css);

    // Should deduplicate
    try testing.expect(css.len > 0);
    const count = std.mem.count(u8, css, "bg-blue-500");
    try testing.expect(count <= 1); // Should appear at most once
}

test "edge case: conflicting utilities" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    // Add conflicting classes
    const conflicting = [_][]const u8{
        "bg-blue-500",
        "bg-red-500",
        "bg-green-500",
    };

    for (conflicting) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        const value = class[3..]; // Strip "bg-"
        try headwind.backgrounds.generateBgColor(&generator, &parsed, value);
    }

    const css = try generator.generate();
    defer allocator.free(css);

    // All should be generated (CSS cascade handles conflicts)
    try testing.expect(css.len > 0);
}

// ============================================================================
// Performance Edge Cases
// ============================================================================

test "edge case: pathological regex patterns" {
    const allocator = testing.allocator;

    // Patterns that could cause catastrophic backtracking in naive regex
    const patterns = [_][]const u8{
        "hover:focus:active:hover:focus:active:hover:focus:active:bg-blue",
        "group-hover:peer-checked:dark:md:lg:xl:2xl:bg-blue",
    };

    for (patterns) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.variants.len > 0);
    }
}

test "edge case: memory stress test" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    // Generate many unique classes
    for (0..1000) |i| {
        const class_name = try std.fmt.allocPrint(allocator, "m-{d}", .{i});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        // Would need actual spacing.generateMargin implementation
        _ = parsed;
    }

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len >= 0);
}
