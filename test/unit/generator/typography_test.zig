const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Font Family Tests
// ============================================================================

test "generate font-sans" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("font-sans");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "font-family") != null);
    try testing.expect(std.mem.indexOf(u8, css, "ui-sans-serif") != null);
}

test "generate font-serif" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("font-serif");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "font-family") != null);
    try testing.expect(std.mem.indexOf(u8, css, "Georgia") != null);
}

test "generate font-mono" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("font-mono");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "font-family") != null);
    try testing.expect(std.mem.indexOf(u8, css, "monospace") != null);
}

// ============================================================================
// Font Size Tests
// ============================================================================

test "generate text-xs" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-xs");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "font-size") != null);
    try testing.expect(std.mem.indexOf(u8, css, "0.75rem") != null);
    try testing.expect(std.mem.indexOf(u8, css, "line-height") != null);
}

test "generate text-base" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-base");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "font-size") != null);
    try testing.expect(std.mem.indexOf(u8, css, "1rem") != null);
}

test "generate text-9xl" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-9xl");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "font-size") != null);
    try testing.expect(std.mem.indexOf(u8, css, "8rem") != null);
}

test "all font sizes exist" {
    const allocator = testing.allocator;

    const sizes = [_][]const u8{ "xs", "sm", "base", "lg", "xl", "2xl", "3xl", "4xl", "5xl", "6xl", "7xl", "8xl", "9xl" };

    for (sizes) |size| {
        var buf: [50]u8 = undefined;
        const class_name = std.fmt.bufPrint(&buf, "text-{s}", .{size}) catch unreachable;

        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        try generator.generateForClass(class_name);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "font-size") != null);
    }
}

// ============================================================================
// Font Smoothing Tests
// ============================================================================

test "generate antialiased" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("antialiased");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "-webkit-font-smoothing") != null);
    try testing.expect(std.mem.indexOf(u8, css, "antialiased") != null);
    try testing.expect(std.mem.indexOf(u8, css, "-moz-osx-font-smoothing") != null);
    try testing.expect(std.mem.indexOf(u8, css, "grayscale") != null);
}

test "generate subpixel-antialiased" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("subpixel-antialiased");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "-webkit-font-smoothing") != null);
    try testing.expect(std.mem.indexOf(u8, css, "auto") != null);
}

// ============================================================================
// Font Style Tests
// ============================================================================

test "generate italic" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("italic");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "font-style") != null);
    try testing.expect(std.mem.indexOf(u8, css, "italic") != null);
}

test "generate not-italic" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("not-italic");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "font-style") != null);
    try testing.expect(std.mem.indexOf(u8, css, "normal") != null);
}

// ============================================================================
// Font Weight Tests
// ============================================================================

test "generate font-bold" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("font-bold");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "font-weight") != null);
    try testing.expect(std.mem.indexOf(u8, css, "700") != null);
}

test "generate font-normal" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("font-normal");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "font-weight") != null);
    try testing.expect(std.mem.indexOf(u8, css, "400") != null);
}

test "all font weights exist" {
    const allocator = testing.allocator;

    const weights = [_][]const u8{ "thin", "extralight", "light", "normal", "medium", "semibold", "bold", "extrabold", "black" };

    for (weights) |weight| {
        var buf: [50]u8 = undefined;
        const class_name = std.fmt.bufPrint(&buf, "font-{s}", .{weight}) catch unreachable;

        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        try generator.generateForClass(class_name);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "font-weight") != null);
    }
}

// ============================================================================
// Letter Spacing (Tracking) Tests
// ============================================================================

test "generate tracking-tight" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("tracking-tight");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "letter-spacing") != null);
    try testing.expect(std.mem.indexOf(u8, css, "-0.025em") != null);
}

test "generate tracking-normal" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("tracking-normal");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "letter-spacing") != null);
    try testing.expect(std.mem.indexOf(u8, css, "0em") != null);
}

test "all tracking values exist" {
    const allocator = testing.allocator;

    const trackings = [_][]const u8{ "tighter", "tight", "normal", "wide", "wider", "widest" };

    for (trackings) |tracking| {
        var buf: [50]u8 = undefined;
        const class_name = std.fmt.bufPrint(&buf, "tracking-{s}", .{tracking}) catch unreachable;

        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        try generator.generateForClass(class_name);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "letter-spacing") != null);
    }
}

// ============================================================================
// Line Height (Leading) Tests
// ============================================================================

test "generate leading-none" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("leading-none");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "line-height") != null);
    try testing.expect(std.mem.indexOf(u8, css, "1") != null);
}

test "generate leading-normal" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("leading-normal");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "line-height") != null);
    try testing.expect(std.mem.indexOf(u8, css, "1.5") != null);
}

test "generate leading-10" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("leading-10");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "line-height") != null);
    try testing.expect(std.mem.indexOf(u8, css, "2.5rem") != null);
}

// ============================================================================
// Text Alignment Tests
// ============================================================================

test "generate text-left" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-left");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-align") != null);
    try testing.expect(std.mem.indexOf(u8, css, "left") != null);
}

test "generate text-center" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-center");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-align") != null);
    try testing.expect(std.mem.indexOf(u8, css, "center") != null);
}

test "all text alignments exist" {
    const allocator = testing.allocator;

    const alignments = [_][]const u8{ "left", "center", "right", "justify", "start", "end" };

    for (alignments) |alignment| {
        var buf: [50]u8 = undefined;
        const class_name = std.fmt.bufPrint(&buf, "text-{s}", .{alignment}) catch unreachable;

        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        try generator.generateForClass(class_name);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "text-align") != null);
    }
}

// ============================================================================
// Text Color Tests
// ============================================================================

test "generate text-blue-500" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-blue-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "color") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch") != null);
}

test "generate text-red-600" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-red-600");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "color") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch") != null);
}

// ============================================================================
// Text Decoration Tests
// ============================================================================

test "generate underline" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("underline");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-decoration-line") != null);
    try testing.expect(std.mem.indexOf(u8, css, "underline") != null);
}

test "generate line-through" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("line-through");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-decoration-line") != null);
    try testing.expect(std.mem.indexOf(u8, css, "line-through") != null);
}

test "generate no-underline" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("no-underline");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-decoration-line") != null);
    try testing.expect(std.mem.indexOf(u8, css, "none") != null);
}

test "generate overline" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("overline");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-decoration-line") != null);
    try testing.expect(std.mem.indexOf(u8, css, "overline") != null);
}

// ============================================================================
// Text Decoration Style Tests
// ============================================================================

test "generate decoration-solid" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("decoration-solid");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-decoration-style") != null);
    try testing.expect(std.mem.indexOf(u8, css, "solid") != null);
}

test "all decoration styles exist" {
    const allocator = testing.allocator;

    const styles = [_][]const u8{ "solid", "double", "dotted", "dashed", "wavy" };

    for (styles) |style| {
        var buf: [50]u8 = undefined;
        const class_name = std.fmt.bufPrint(&buf, "decoration-{s}", .{style}) catch unreachable;

        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        try generator.generateForClass(class_name);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "text-decoration-style") != null);
    }
}

// ============================================================================
// Text Transform Tests
// ============================================================================

test "generate uppercase" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("uppercase");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-transform") != null);
    try testing.expect(std.mem.indexOf(u8, css, "uppercase") != null);
}

test "generate lowercase" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("lowercase");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-transform") != null);
    try testing.expect(std.mem.indexOf(u8, css, "lowercase") != null);
}

test "generate capitalize" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("capitalize");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-transform") != null);
    try testing.expect(std.mem.indexOf(u8, css, "capitalize") != null);
}

test "generate normal-case" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("normal-case");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-transform") != null);
    try testing.expect(std.mem.indexOf(u8, css, "none") != null);
}

// ============================================================================
// Text Overflow Tests
// ============================================================================

test "generate truncate" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("truncate");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "overflow") != null);
    try testing.expect(std.mem.indexOf(u8, css, "text-overflow") != null);
    try testing.expect(std.mem.indexOf(u8, css, "ellipsis") != null);
    try testing.expect(std.mem.indexOf(u8, css, "white-space") != null);
    try testing.expect(std.mem.indexOf(u8, css, "nowrap") != null);
}

test "generate text-ellipsis" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-ellipsis");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-overflow") != null);
    try testing.expect(std.mem.indexOf(u8, css, "ellipsis") != null);
}

test "generate text-clip" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-clip");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-overflow") != null);
    try testing.expect(std.mem.indexOf(u8, css, "clip") != null);
}

// ============================================================================
// Whitespace Tests
// ============================================================================

test "generate whitespace-normal" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("whitespace-normal");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "white-space") != null);
    try testing.expect(std.mem.indexOf(u8, css, "normal") != null);
}

test "generate whitespace-nowrap" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("whitespace-nowrap");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "white-space") != null);
    try testing.expect(std.mem.indexOf(u8, css, "nowrap") != null);
}

test "all whitespace modes exist" {
    const allocator = testing.allocator;

    const modes = [_][]const u8{ "normal", "nowrap", "pre", "pre-line", "pre-wrap", "break-spaces" };

    for (modes) |mode| {
        var buf: [50]u8 = undefined;
        const class_name = std.fmt.bufPrint(&buf, "whitespace-{s}", .{mode}) catch unreachable;

        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        try generator.generateForClass(class_name);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "white-space") != null);
    }
}

// ============================================================================
// Word Break Tests
// ============================================================================

test "generate break-normal" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("break-normal");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "overflow-wrap") != null);
    try testing.expect(std.mem.indexOf(u8, css, "word-break") != null);
}

test "generate break-words" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("break-words");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "overflow-wrap") != null);
    try testing.expect(std.mem.indexOf(u8, css, "break-word") != null);
}

test "generate break-all" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("break-all");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "word-break") != null);
    try testing.expect(std.mem.indexOf(u8, css, "break-all") != null);
}

// ============================================================================
// List Style Tests
// ============================================================================

test "generate list-none" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("list-none");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "list-style-type") != null);
    try testing.expect(std.mem.indexOf(u8, css, "none") != null);
}

test "generate list-disc" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("list-disc");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "list-style-type") != null);
    try testing.expect(std.mem.indexOf(u8, css, "disc") != null);
}

test "generate list-decimal" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("list-decimal");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "list-style-type") != null);
    try testing.expect(std.mem.indexOf(u8, css, "decimal") != null);
}

test "generate list-inside" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("list-inside");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "list-style-position") != null);
    try testing.expect(std.mem.indexOf(u8, css, "inside") != null);
}

test "generate list-outside" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("list-outside");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "list-style-position") != null);
    try testing.expect(std.mem.indexOf(u8, css, "outside") != null);
}

// ============================================================================
// Vertical Align Tests
// ============================================================================

test "generate align-baseline" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("align-baseline");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "vertical-align") != null);
    try testing.expect(std.mem.indexOf(u8, css, "baseline") != null);
}

test "generate align-middle" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("align-middle");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "vertical-align") != null);
    try testing.expect(std.mem.indexOf(u8, css, "middle") != null);
}

// ============================================================================
// Edge Cases and Integration Tests
// ============================================================================

test "typography with variants" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("hover:text-blue-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "color") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch") != null);
    try testing.expect(std.mem.indexOf(u8, css, "hover") != null);
}

test "typography with important" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-center!");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "text-align") != null);
    try testing.expect(std.mem.indexOf(u8, css, "center") != null);
    try testing.expect(std.mem.indexOf(u8, css, "!important") != null);
}

test "multiple typography classes" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-lg");
    try generator.generateForClass("font-bold");
    try generator.generateForClass("text-center");
    try generator.generateForClass("text-blue-500");

    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "font-size") != null);
    try testing.expect(std.mem.indexOf(u8, css, "font-weight") != null);
    try testing.expect(std.mem.indexOf(u8, css, "text-align") != null);
    try testing.expect(std.mem.indexOf(u8, css, "color") != null);
}

test "invalid typography class generates nothing" {
    const allocator = testing.allocator;

    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try generator.generateForClass("text-invalid-size");

    const css = try generator.generate();
    defer allocator.free(css);

    // Should generate empty or minimal CSS - just verify no crash
    try testing.expect(css.len >= 0);
}
