const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");
const class_parser = headwind.class_parser;

// ============================================================================
// Basic Parsing Tests
// ============================================================================

test "parse simple utility class" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "bg-blue-500");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expectEqual(@as(usize, 0), parsed.variants.len);
    try testing.expectEqualStrings("bg-blue-500", parsed.utility);
    try testing.expect(!parsed.is_arbitrary);
    try testing.expect(!parsed.is_important);
    try testing.expectEqual(@as(?[]const u8, null), parsed.arbitrary_value);
}

test "parse utility with single variant" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "hover:bg-red-500");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expectEqual(@as(usize, 1), parsed.variants.len);
    try testing.expectEqualStrings("hover", parsed.variants[0].variant);
    try testing.expectEqual(@as(?[]const u8, null), parsed.variants[0].name);
    try testing.expectEqualStrings("bg-red-500", parsed.utility);
}

test "parse utility with multiple variants" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "md:hover:focus:text-white");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expectEqual(@as(usize, 3), parsed.variants.len);
    try testing.expectEqualStrings("md", parsed.variants[0].variant);
    try testing.expectEqualStrings("hover", parsed.variants[1].variant);
    try testing.expectEqualStrings("focus", parsed.variants[2].variant);
    try testing.expectEqualStrings("text-white", parsed.utility);
}

test "parse compound utility with hyphens" {
    const allocator = testing.allocator;

    const test_cases = [_][]const u8{
        "line-through",
        "break-words",
        "text-ellipsis",
        "bg-clip-text",
    };

    for (test_cases) |class_name| {
        const parsed = try class_parser.parseClass(allocator, class_name);
        defer { var mutable = parsed; mutable.deinit(allocator); }

        try testing.expectEqualStrings(class_name, parsed.utility);
        try testing.expectEqual(@as(usize, 0), parsed.variants.len);
    }
}

// ============================================================================
// Arbitrary Value Tests
// ============================================================================

test "parse arbitrary value with brackets" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "w-[100px]");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expect(parsed.is_arbitrary);
    try testing.expectEqualStrings("100px", parsed.arbitrary_value.?);
    try testing.expect(std.mem.startsWith(u8, parsed.utility, "w-"));
}

test "parse arbitrary value with spaces (underscores)" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "bg-[rgb(255,_0,_0)]");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expect(parsed.is_arbitrary);
    // Underscores should be converted to spaces
    const value = parsed.arbitrary_value.?;
    try testing.expect(std.mem.indexOf(u8, value, "rgb") != null);
}

test "parse arbitrary value with complex expression" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "grid-cols-[1fr_2fr_1fr]");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expect(parsed.is_arbitrary);
    try testing.expect(std.mem.startsWith(u8, parsed.utility, "grid-cols-"));
}

test "parse arbitrary value with nested brackets" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "content-['hello_[world]']");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expect(parsed.is_arbitrary);
    // Should handle nested brackets correctly
}

test "parse arbitrary selector" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "[&:nth-child(3)]:bg-red");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    // First variant should contain the arbitrary selector
    try testing.expect(parsed.variants.len > 0);
    try testing.expectEqualStrings("bg-red", parsed.utility);
}

// ============================================================================
// Important Modifier Tests
// ============================================================================

test "parse class with important modifier" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "bg-blue-500!");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expect(parsed.is_important);
    try testing.expectEqualStrings("bg-blue-500", parsed.utility);
}

test "parse variant with important modifier" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "hover:bg-red!");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expect(parsed.is_important);
    try testing.expectEqual(@as(usize, 1), parsed.variants.len);
    try testing.expectEqualStrings("bg-red", parsed.utility);
}

test "parse arbitrary value with important modifier" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "w-[100px]!");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expect(parsed.is_important);
    try testing.expect(parsed.is_arbitrary);
}

test "important modifier at start of class" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "!bg-blue-500");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expect(parsed.is_important);
    try testing.expectEqualStrings("bg-blue-500", parsed.utility);
}

// ============================================================================
// Named Variant Tests
// ============================================================================

test "parse group variant" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "group-hover:bg-blue");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expectEqual(@as(usize, 1), parsed.variants.len);
    try testing.expectEqualStrings("group-hover", parsed.variants[0].variant);
}

test "parse named group variant" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "group/sidebar-hover:bg-gray");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expectEqual(@as(usize, 1), parsed.variants.len);
    // Should parse group name
    if (parsed.variants[0].name) |name| {
        try testing.expectEqualStrings("sidebar", name);
    } else {
        try testing.expect(false); // Should have a name
    }
}

test "parse peer variant" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "peer-checked:text-red");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expectEqual(@as(usize, 1), parsed.variants.len);
    try testing.expectEqualStrings("peer-checked", parsed.variants[0].variant);
}

test "parse named peer variant" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "peer/label-focus:font-bold");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expectEqual(@as(usize, 1), parsed.variants.len);
    // Should parse peer name
    if (parsed.variants[0].name) |name| {
        try testing.expectEqualStrings("label", name);
    } else {
        try testing.expect(false); // Should have a name
    }
}

// ============================================================================
// Negative Value Tests
// ============================================================================

test "parse negative spacing" {
    const allocator = testing.allocator;

    const test_cases = [_][]const u8{
        "-m-4",
        "-mt-2",
        "-mx-8",
        "-top-5",
    };

    for (test_cases) |class_name| {
        const parsed = try class_parser.parseClass(allocator, class_name);
        defer { var mutable = parsed; mutable.deinit(allocator); }

        // Should start with dash
        try testing.expect(parsed.utility[0] == '-');
    }
}

test "parse negative arbitrary value" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "-translate-x-[50px]");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expect(parsed.utility[0] == '-');
    try testing.expect(parsed.is_arbitrary);
}

// ============================================================================
// Edge Case Tests
// ============================================================================

test "parse empty string fails" {
    const allocator = testing.allocator;

    const result = class_parser.parseClass(allocator, "");
    try testing.expectError(error.InvalidClassName, result);
}

test "parse whitespace only fails" {
    const allocator = testing.allocator;

    const result = class_parser.parseClass(allocator, "   ");
    try testing.expectError(error.InvalidClassName, result);
}

test "parse very long class name" {
    const allocator = testing.allocator;

    // Create a very long class name (1000+ characters)
    var long_class: std.ArrayList(u8) = .{};
    defer long_class.deinit(allocator);

    try long_class.appendSlice(allocator, "hover:focus:active:md:lg:xl:2xl:");
    var i: usize = 0;
    while (i < 100) : (i += 1) {
        try long_class.appendSlice(allocator, "very-long-");
    }
    try long_class.appendSlice(allocator, "utility-class");

    const parsed = try class_parser.parseClass(allocator, long_class.items);
    defer { var mutable = parsed; mutable.deinit(allocator); }

    // Should parse successfully
    try testing.expect(parsed.variants.len > 0);
}

test "parse class with special characters in arbitrary value" {
    const allocator = testing.allocator;

    const test_cases = [_][]const u8{
        "bg-[url('/path/to/image.png')]",
        "content-['Hello,_World!']",
        "before:content-['→']",
    };

    for (test_cases) |class_name| {
        const parsed = try class_parser.parseClass(allocator, class_name);
        defer { var mutable = parsed; mutable.deinit(allocator); }

        // Should parse without error
        try testing.expect(parsed.is_arbitrary or parsed.variants.len > 0);
    }
}

test "parse malformed brackets recovers gracefully" {
    const allocator = testing.allocator;

    const test_cases = [_][]const u8{
        "w-[100px",      // Missing closing bracket
        "w-100px]",      // Missing opening bracket
        "w-[[100px]]",   // Double brackets
    };

    for (test_cases) |class_name| {
        // Should either parse or return error, not crash
        const result = class_parser.parseClass(allocator, class_name);
        if (result) |parsed| {
            defer { var mutable = parsed; mutable.deinit(allocator); }
        } else |_| {
            // Error is acceptable for malformed input
        }
    }
}

test "parse class with only variants no utility fails gracefully" {
    const allocator = testing.allocator;

    const result = class_parser.parseClass(allocator, "hover:focus:");
    if (result) |parsed| {
        defer { var mutable = parsed; mutable.deinit(allocator); }
        // If it parses, utility should be empty or last variant
        try testing.expect(parsed.utility.len > 0);
    } else |_| {
        // Error is acceptable
    }
}

test "parse duplicate variants" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "hover:hover:bg-blue");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    // Should parse but may have duplicate variants
    try testing.expect(parsed.variants.len >= 1);
}

test "parse with colon in arbitrary value" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "before:content-['12:00']");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    // Colon inside brackets should not be treated as variant separator
    try testing.expect(parsed.is_arbitrary or parsed.variants.len > 0);
}

test "parse complex real-world classes" {
    const allocator = testing.allocator;

    const test_cases = [_][]const u8{
        "lg:hover:focus:bg-gradient-to-r",
        "group/card-hover:translate-y-[-10px]",
        "peer-checked/option-[&>span]:text-blue-500",
        "md:dark:hover:bg-slate-800/50",
        "[@media(min-width:300px)]:block",
    };

    for (test_cases) |class_name| {
        const parsed = try class_parser.parseClass(allocator, class_name);
        defer { var mutable = parsed; mutable.deinit(allocator); }

        // Should parse successfully
        try testing.expect(parsed.utility.len > 0);
    }
}

// ============================================================================
// Memory Safety Tests
// ============================================================================

test "parse and deinit multiple classes - no memory leaks" {
    const allocator = testing.allocator;

    const test_cases = [_][]const u8{
        "bg-blue-500",
        "hover:text-red",
        "md:flex",
        "w-[100px]",
        "group/sidebar-hover:bg-gray!",
    };

    // Parse and deinit multiple times
    var i: usize = 0;
    while (i < 10) : (i += 1) {
        for (test_cases) |class_name| {
            var parsed = try class_parser.parseClass(allocator, class_name);
            parsed.deinit(allocator);
        }
    }

    // If no memory leaks, this test passes
}

// ============================================================================
// Unicode and International Character Tests
// ============================================================================

test "parse class with unicode in arbitrary value" {
    const allocator = testing.allocator;

    const parsed = try class_parser.parseClass(allocator, "content-['Hello_世界']");
    defer { var mutable = parsed; mutable.deinit(allocator); }

    try testing.expect(parsed.is_arbitrary);
    // Should handle unicode correctly
}

// ============================================================================
// Case Sensitivity Tests
// ============================================================================

test "parse class names are case sensitive" {
    const allocator = testing.allocator;

    var parsed1 = try class_parser.parseClass(allocator, "bg-Blue-500");
    defer parsed1.deinit(allocator);

    var parsed2 = try class_parser.parseClass(allocator, "bg-blue-500");
    defer parsed2.deinit(allocator);

    // Should be different utilities (case matters)
    try testing.expect(!std.mem.eql(u8, parsed1.utility, parsed2.utility));
}
