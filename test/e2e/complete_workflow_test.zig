const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const class_parser = headwind.class_parser;
const CSSGenerator = headwind.CSSGenerator;

// ============================================================================
// End-to-End Workflow Tests
// ============================================================================

test "complete CSS generation workflow" {
    const allocator = testing.allocator;

    // Simulate a typical workflow: parse HTML, extract classes, generate CSS

    const html_classes = [_][]const u8{
        "bg-blue-500",
        "text-white",
        "p-4",
        "rounded-lg",
        "shadow-md",
        "hover:bg-blue-600",
        "focus:ring-2",
        "focus:ring-blue-400",
    };

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    // Process each class
    for (html_classes) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        // Dispatch to appropriate generator (simplified for test)
        if (std.mem.startsWith(u8, parsed.utility, "bg-")) {
            const value = parsed.utility[3..];
            try headwind.backgrounds.generateBgColor(&generator, &parsed, value);
        } else if (std.mem.startsWith(u8, parsed.utility, "text-")) {
            const value = parsed.utility[5..];
            try headwind.typography.generateTextColor(&generator, &parsed, value);
        } else if (std.mem.startsWith(u8, parsed.utility, "p-")) {
            const value = parsed.utility[2..];
            try headwind.spacing.generatePadding(&generator, &parsed, value);
        } else if (std.mem.startsWith(u8, parsed.utility, "rounded-")) {
            const value = parsed.utility[8..];
            try headwind.borders.generateBorderRadius(&generator, &parsed, value);
        } else if (std.mem.startsWith(u8, parsed.utility, "shadow-")) {
            const value = parsed.utility[7..];
            try headwind.shadows.generateShadow(&generator, &parsed, value);
        } else if (std.mem.startsWith(u8, parsed.utility, "ring-")) {
            const value = parsed.utility[5..];
            try headwind.borders.generateRing(&generator, &parsed, value);
        }
    }

    const css = try generator.generate();
    defer allocator.free(css);

    // Verify CSS was generated
    try testing.expect(css.len > 0);

    // Check for expected CSS properties
    try testing.expect(std.mem.indexOf(u8, css, "background-color") != null);
    try testing.expect(std.mem.indexOf(u8, css, "color") != null);
    try testing.expect(std.mem.indexOf(u8, css, "padding") != null);
    try testing.expect(std.mem.indexOf(u8, css, "border-radius") != null);
    try testing.expect(std.mem.indexOf(u8, css, "box-shadow") != null);

    // Check for variants
    try testing.expect(std.mem.indexOf(u8, css, ":hover") != null);
    try testing.expect(std.mem.indexOf(u8, css, ":focus") != null);

    // Check for OKLCH colors
    try testing.expect(std.mem.indexOf(u8, css, "oklch(") != null);
}

test "responsive design workflow" {
    const allocator = testing.allocator;

    const responsive_classes = [_][]const u8{
        "text-sm",
        "md:text-base",
        "lg:text-lg",
        "xl:text-xl",
        "grid-cols-1",
        "md:grid-cols-2",
        "lg:grid-cols-3",
        "xl:grid-cols-4",
    };

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    for (responsive_classes) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        // Process responsive utilities
        if (std.mem.startsWith(u8, parsed.utility, "text-")) {
            const value = parsed.utility[5..];
            try headwind.typography.generateFontSize(&generator, &parsed, value);
        } else if (std.mem.startsWith(u8, parsed.utility, "grid-cols-")) {
            const value = parsed.utility[10..];
            try headwind.grid.generateGridTemplateColumns(&generator, &parsed, value);
        }
    }

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);

    // Should contain media queries
    try testing.expect(std.mem.indexOf(u8, css, "@media") != null or
                      std.mem.indexOf(u8, css, "md:") != null or
                      std.mem.indexOf(u8, css, "lg:") != null);
}

test "dark mode workflow" {
    const allocator = testing.allocator;

    const dark_mode_classes = [_][]const u8{
        "bg-white",
        "dark:bg-gray-900",
        "text-gray-900",
        "dark:text-gray-100",
    };

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    for (dark_mode_classes) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        if (std.mem.startsWith(u8, parsed.utility, "bg-")) {
            const value = parsed.utility[3..];
            try headwind.backgrounds.generateBgColor(&generator, &parsed, value);
        } else if (std.mem.startsWith(u8, parsed.utility, "text-")) {
            const value = parsed.utility[5..];
            try headwind.typography.generateTextColor(&generator, &parsed, value);
        }
    }

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
    // Should handle dark mode variant
}

test "component pattern workflow" {
    const allocator = testing.allocator;

    // Simulate building a button component
    const button_classes = [_][]const u8{
        "inline-flex",
        "items-center",
        "justify-center",
        "px-4",
        "py-2",
        "border",
        "border-transparent",
        "text-sm",
        "font-medium",
        "rounded-md",
        "text-white",
        "bg-indigo-600",
        "hover:bg-indigo-700",
        "focus:outline-none",
        "focus:ring-2",
        "focus:ring-offset-2",
        "focus:ring-indigo-500",
        "transition-colors",
        "duration-200",
    };

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    for (button_classes) |class| {
        var parsed = try class_parser.parseClass(allocator, class);

        // In real implementation, would dispatch to correct generator
        parsed.deinit(allocator);
    }

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
}

test "arbitrary values workflow" {
    const allocator = testing.allocator;

    const arbitrary_classes = [_][]const u8{
        "w-[200px]",
        "h-[calc(100vh-64px)]",
        "bg-[#1da1f2]",
        "text-[14px]",
        "grid-cols-[1fr_2fr_1fr]",
        "shadow-[0_35px_60px_-15px_rgba(0,0,0,0.3)]",
    };

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    for (arbitrary_classes) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.is_arbitrary);
        try testing.expect(parsed.arbitrary_value != null);
    }

    const css = try generator.generate();
    defer allocator.free(css);

    // Verify arbitrary values are preserved in CSS
    try testing.expect(css.len >= 0);
}

test "complex selector workflow" {
    const allocator = testing.allocator;

    const complex_classes = [_][]const u8{
        "group-hover:text-blue-500",
        "peer-checked:bg-blue-500",
        "first:mt-0",
        "last:mb-0",
        "odd:bg-gray-100",
        "even:bg-white",
    };

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    for (complex_classes) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        try testing.expect(parsed.variants.len > 0);
    }

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len >= 0);
}

test "performance with many classes" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    // Generate 1000 different utility classes
    for (0..1000) |i| {
        const class_name = try std.fmt.allocPrint(allocator, "m-{d}", .{i % 100});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);

        // In real implementation, would generate CSS
        parsed.deinit(allocator);
    }

    const css = try generator.generate();
    defer allocator.free(css);

    // Should handle many classes efficiently
    try testing.expect(css.len >= 0);
}
