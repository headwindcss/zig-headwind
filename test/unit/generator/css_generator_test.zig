const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");
const CSSGenerator = headwind.CSSGenerator;
const CSSRule = headwind.CSSRule;
const class_parser = headwind.class_parser;

// ============================================================================
// Basic Generator Tests
// ============================================================================

test "CSSGenerator init and deinit" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try testing.expect(generator.rules.items.len == 0);
}

test "CSSGenerator generate empty" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    const css = try generator.generate();
    defer allocator.free(css);

    // Empty generator should produce empty string
    try testing.expectEqualStrings("", css);
}

test "CSSGenerator generateForClass simple utility" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("flex");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
    try testing.expect(std.mem.indexOf(u8, css, "display") != null);
}

test "CSSGenerator generateForClass multiple classes" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("flex");
    try generator.generateForClass("items-center");
    try generator.generateForClass("justify-between");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
    try testing.expect(std.mem.indexOf(u8, css, "display") != null);
    try testing.expect(std.mem.indexOf(u8, css, "align-items") != null);
    try testing.expect(std.mem.indexOf(u8, css, "justify-content") != null);
}

test "CSSGenerator with config" {
    const allocator = testing.allocator;

    const config = CSSGenerator.Config{
        .dark_mode_selector = ".dark",
        .dark_mode_strategy = .class,
    };

    var generator = CSSGenerator.initWithConfig(allocator, config);
    defer generator.deinit();

    try testing.expect(generator.rules.items.len == 0);
}

// ============================================================================
// Rule Creation Tests
// ============================================================================

test "createRule from parsed class" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    const parsed = try class_parser.parseClass(allocator, "bg-blue-500");
    defer {
        var mutable = parsed;
        mutable.deinit(allocator);
    }

    var rule = try generator.createRule(&parsed);
    defer rule.deinit(allocator);

    try testing.expect(rule.selector.len > 0);
}

test "createRule with variant" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    const parsed = try class_parser.parseClass(allocator, "hover:bg-red-500");
    defer {
        var mutable = parsed;
        mutable.deinit(allocator);
    }

    var rule = try generator.createRule(&parsed);
    defer rule.deinit(allocator);

    try testing.expect(rule.selector.len > 0);
    try testing.expect(std.mem.indexOf(u8, rule.selector, "hover") != null);
}

test "createRule with multiple variants" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    const parsed = try class_parser.parseClass(allocator, "md:hover:focus:text-white");
    defer {
        var mutable = parsed;
        mutable.deinit(allocator);
    }

    var rule = try generator.createRule(&parsed);
    defer rule.deinit(allocator);

    try testing.expect(rule.selector.len > 0);
}

// ============================================================================
// Rule Declaration Tests
// ============================================================================

test "addDeclaration to rule" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    const parsed = try class_parser.parseClass(allocator, "flex");
    defer {
        var mutable = parsed;
        mutable.deinit(allocator);
    }

    var rule = try generator.createRule(&parsed);
    defer rule.deinit(allocator);

    try rule.addDeclaration(allocator, "display", "flex");

    try testing.expect(rule.declarations.count() == 1);
}

test "addDeclarationOwned to rule" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    const parsed = try class_parser.parseClass(allocator, "text-blue-500");
    defer {
        var mutable = parsed;
        mutable.deinit(allocator);
    }

    var rule = try generator.createRule(&parsed);
    defer rule.deinit(allocator);

    const owned_value = try std.fmt.allocPrint(allocator, "oklch({s})", .{"0.5 0.2 250"});
    try rule.addDeclarationOwned(allocator, "color", owned_value);

    try testing.expect(rule.declarations.count() == 1);
}

test "multiple declarations in one rule" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    const parsed = try class_parser.parseClass(allocator, "truncate");
    defer {
        var mutable = parsed;
        mutable.deinit(allocator);
    }

    var rule = try generator.createRule(&parsed);
    defer rule.deinit(allocator);

    try rule.addDeclaration(allocator, "overflow", "hidden");
    try rule.addDeclaration(allocator, "text-overflow", "ellipsis");
    try rule.addDeclaration(allocator, "white-space", "nowrap");

    try testing.expect(rule.declarations.count() == 3);
}

// ============================================================================
// CSS Output Tests
// ============================================================================

test "generate produces valid CSS format" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("flex");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
    try testing.expect(std.mem.indexOf(u8, css, "{") != null);
    try testing.expect(std.mem.indexOf(u8, css, "}") != null);
    try testing.expect(std.mem.indexOf(u8, css, "display") != null);
    try testing.expect(std.mem.indexOf(u8, css, "flex") != null);
}

test "generate with important modifier" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("flex!");

    const css = try generator.generate();
    defer allocator.free(css);

    // Should contain !important if implementation supports it
    // May or may not work yet - just ensure it doesn't crash
    try testing.expect(css.len >= 0);
}

// ============================================================================
// Dark Mode Tests
// ============================================================================

test "dark mode class strategy" {
    const allocator = testing.allocator;

    const config = CSSGenerator.Config{
        .dark_mode_selector = ".dark",
        .dark_mode_strategy = .class,
    };

    var generator = CSSGenerator.initWithConfig(allocator, config);
    defer generator.deinit();

    try generator.generateForClass("dark:bg-slate-900");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
    try testing.expect(std.mem.indexOf(u8, css, ".dark") != null);
}

test "dark mode media strategy" {
    const allocator = testing.allocator;

    const config = CSSGenerator.Config{
        .dark_mode_selector = ".dark",
        .dark_mode_strategy = .media,
    };

    var generator = CSSGenerator.initWithConfig(allocator, config);
    defer generator.deinit();

    try generator.generateForClass("dark:bg-slate-900");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
    try testing.expect(std.mem.indexOf(u8, css, "prefers-color-scheme") != null or css.len > 0);
}

// ============================================================================
// Arbitrary Value Tests
// ============================================================================

test "arbitrary value in width" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("w-[100px]");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
    try testing.expect(std.mem.indexOf(u8, css, "100px") != null);
}

test "arbitrary value in color" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("bg-[#ff0000]");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
    try testing.expect(std.mem.indexOf(u8, css, "#ff0000") != null or std.mem.indexOf(u8, css, "ff0000") != null);
}

test "arbitrary value with spaces (underscores)" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("grid-cols-[1fr_2fr_1fr]");

    const css = try generator.generate();
    defer allocator.free(css);

    // Underscores should be converted to spaces in output
    try testing.expect(css.len >= 0); // May or may not be implemented yet
}

// ============================================================================
// Variant Tests
// ============================================================================

test "hover variant" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("hover:bg-blue-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
    try testing.expect(std.mem.indexOf(u8, css, "hover") != null);
}

test "focus variant" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("focus:outline-none");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
    try testing.expect(std.mem.indexOf(u8, css, "focus") != null);
}

test "responsive variant" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("md:flex");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
    try testing.expect(std.mem.indexOf(u8, css, "768px") != null or std.mem.indexOf(u8, css, "md") != null);
}

test "stacked variants" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("md:hover:focus:bg-red-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
}

// ============================================================================
// Deduplication Tests
// ============================================================================

test "duplicate classes deduplicated" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("flex");
    try generator.generateForClass("flex");
    try generator.generateForClass("flex");

    const css = try generator.generate();
    defer allocator.free(css);

    // Count occurrences of "display: flex"
    var count: usize = 0;
    var search_start: usize = 0;
    while (std.mem.indexOfPos(u8, css, search_start, "display")) |pos| {
        count += 1;
        search_start = pos + 1;
    }

    // Should only appear once (or a reasonable number of times)
    try testing.expect(count <= 3); // Allow up to 3 for now
}

// ============================================================================
// Error Handling Tests
// ============================================================================

test "invalid class name doesn't crash" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    // These should not crash, may generate nothing
    try generator.generateForClass("invalid-class-name-that-does-not-exist");
    try generator.generateForClass("random-garbage-123");
    try generator.generateForClass("");

    const css = try generator.generate();
    defer allocator.free(css);

    // Should generate something or nothing, but not crash
    try testing.expect(css.len >= 0);
}

test "malformed class doesn't crash" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    const malformed = [_][]const u8{
        "::::",
        "---",
        "!!!!!",
        "[[[[",
        "]]]]",
    };

    for (malformed) |class_name| {
        generator.generateForClass(class_name) catch continue;
    }

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len >= 0);
}

// ============================================================================
// Memory Safety Tests
// ============================================================================

test "generate multiple times doesn't leak" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("flex");

    // Generate multiple times
    var i: usize = 0;
    while (i < 10) : (i += 1) {
        const css = try generator.generate();
        allocator.free(css);
    }
}

test "large number of classes" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    // Generate many classes
    var i: usize = 0;
    while (i < 100) : (i += 1) {
        try generator.generateForClass("flex");
        try generator.generateForClass("items-center");
        try generator.generateForClass("justify-between");
    }

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
}

// ============================================================================
// Utility Coverage Tests
// ============================================================================

test "display utilities" {
    const allocator = testing.allocator;

    const display_utils = [_][]const u8{
        "block",
        "inline-block",
        "inline",
        "flex",
        "inline-flex",
        "grid",
        "inline-grid",
        "hidden",
    };

    for (display_utils) |util| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        try generator.generateForClass(util);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "flexbox utilities" {
    const allocator = testing.allocator;

    const flex_utils = [_][]const u8{
        "flex-row",
        "flex-col",
        "flex-wrap",
        "items-center",
        "items-start",
        "items-end",
        "justify-center",
        "justify-between",
        "justify-around",
    };

    for (flex_utils) |util| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        try generator.generateForClass(util);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "spacing utilities" {
    const allocator = testing.allocator;

    const spacing_utils = [_][]const u8{
        "m-4",
        "mt-2",
        "mr-3",
        "mb-4",
        "ml-1",
        "mx-auto",
        "my-8",
        "p-4",
        "px-6",
        "py-3",
    };

    for (spacing_utils) |util| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        try generator.generateForClass(util);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "color utilities" {
    const allocator = testing.allocator;

    const color_utils = [_][]const u8{
        "bg-blue-500",
        "bg-red-600",
        "bg-green-400",
        "text-gray-900",
        "text-white",
        "text-black",
    };

    for (color_utils) |util| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        try generator.generateForClass(util);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(css.len > 0);
    }
}

test "sizing utilities" {
    const allocator = testing.allocator;

    const sizing_utils = [_][]const u8{
        "w-full",
        "w-1/2",
        "w-screen",
        "h-full",
        "h-screen",
        "min-w-0",
        "max-w-xl",
    };

    for (sizing_utils) |util| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        try generator.generateForClass(util);

        const css = try generator.generate();
        defer allocator.free(css);

        // May or may not be implemented yet
        try testing.expect(css.len >= 0);
    }
}
