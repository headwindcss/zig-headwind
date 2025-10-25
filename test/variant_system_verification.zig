const std = @import("std");
const testing = std.testing;

// This test file verifies that ALL 60+ variants from the Variant System
// are properly implemented and accessible in the variant registry

const VariantRegistry = @import("../src/variants/registry.zig").VariantRegistry;
const VariantType = @import("../src/variants/registry.zig").VariantType;

test "verify all pseudo-class variants implemented (29 total)" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    // All 29 pseudo-class variants
    const pseudo_class_variants = [_][]const u8{
        "hover",
        "focus",
        "focus-visible",
        "focus-within",
        "active",
        "visited",
        "target",
        "first",
        "last",
        "only",
        "odd",
        "even",
        "first-of-type",
        "last-of-type",
        "only-of-type",
        "empty",
        "disabled",
        "enabled",
        "checked",
        "indeterminate",
        "default",
        "required",
        "valid",
        "invalid",
        "in-range",
        "out-of-range",
        "placeholder-shown",
        "autofill",
        "read-only",
    };

    for (pseudo_class_variants) |variant_name| {
        const variant = registry.get(variant_name);
        try testing.expect(variant != null);
        try testing.expect(variant.?.type == .pseudo_class);
        try testing.expect(variant.?.order >= 100 and variant.?.order < 200);
    }

    // Verify count
    var count: usize = 0;
    for (pseudo_class_variants) |_| count += 1;
    try testing.expectEqual(@as(usize, 29), count);
}

test "verify all pseudo-element variants implemented (9 total)" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const pseudo_element_variants = [_][]const u8{
        "before",
        "after",
        "first-letter",
        "first-line",
        "marker",
        "selection",
        "file",
        "backdrop",
        "placeholder",
    };

    for (pseudo_element_variants) |variant_name| {
        const variant = registry.get(variant_name);
        try testing.expect(variant != null);
        try testing.expect(variant.?.type == .pseudo_element);
        try testing.expect(variant.?.order >= 200 and variant.?.order < 300);
    }

    var count: usize = 0;
    for (pseudo_element_variants) |_| count += 1;
    try testing.expectEqual(@as(usize, 9), count);
}

test "verify all state variants implemented (2 total)" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const state_variants = [_][]const u8{
        "open",
        "closed",
    };

    for (state_variants) |variant_name| {
        const variant = registry.get(variant_name);
        try testing.expect(variant != null);
        try testing.expect(variant.?.type == .state);
        try testing.expect(variant.?.order >= 300 and variant.?.order < 400);
    }

    var count: usize = 0;
    for (state_variants) |_| count += 1;
    try testing.expectEqual(@as(usize, 2), count);
}

test "verify all media query variants implemented (9 total)" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const media_query_variants = [_][]const u8{
        "prefers-reduced-motion",
        "prefers-color-scheme-dark",
        "prefers-color-scheme-light",
        "prefers-contrast-more",
        "prefers-contrast-less",
        "dark",
        "light",
        "motion-safe",
        "motion-reduce",
    };

    for (media_query_variants) |variant_name| {
        const variant = registry.get(variant_name);
        try testing.expect(variant != null);
        try testing.expect(variant.?.type == .media_query);
        try testing.expect(variant.?.order >= 400 and variant.?.order < 600);
    }

    var count: usize = 0;
    for (media_query_variants) |_| count += 1;
    try testing.expectEqual(@as(usize, 9), count);
}

test "verify print variant implemented (1 total)" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const variant = registry.get("print");
    try testing.expect(variant != null);
    try testing.expect(variant.?.type == .print);
    try testing.expectEqual(@as(u32, 500), variant.?.order);
    try testing.expectEqualStrings("@media print", variant.?.css_selector);
}

test "verify all supports query variants implemented (2 total)" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const supports_variants = [_][]const u8{
        "supports-grid",
        "supports-backdrop-blur",
    };

    for (supports_variants) |variant_name| {
        const variant = registry.get(variant_name);
        try testing.expect(variant != null);
        try testing.expect(variant.?.type == .supports_query);
        try testing.expect(variant.?.order >= 600 and variant.?.order < 700);
    }

    var count: usize = 0;
    for (supports_variants) |_| count += 1;
    try testing.expectEqual(@as(usize, 2), count);
}

test "verify all ARIA attribute variants implemented (8 total)" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const aria_variants = [_][]const u8{
        "aria-checked",
        "aria-disabled",
        "aria-expanded",
        "aria-hidden",
        "aria-pressed",
        "aria-readonly",
        "aria-required",
        "aria-selected",
    };

    for (aria_variants) |variant_name| {
        const variant = registry.get(variant_name);
        try testing.expect(variant != null);
        try testing.expect(variant.?.type == .aria_attribute);
        try testing.expect(variant.?.order >= 700 and variant.?.order < 800);
    }

    var count: usize = 0;
    for (aria_variants) |_| count += 1;
    try testing.expectEqual(@as(usize, 8), count);
}

test "verify all data attribute variants implemented (3 total)" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const data_variants = [_][]const u8{
        "data-active",
        "data-disabled",
        "data-selected",
    };

    for (data_variants) |variant_name| {
        const variant = registry.get(variant_name);
        try testing.expect(variant != null);
        try testing.expect(variant.?.type == .data_attribute);
        try testing.expect(variant.?.order >= 800 and variant.?.order < 900);
    }

    var count: usize = 0;
    for (data_variants) |_| count += 1;
    try testing.expectEqual(@as(usize, 3), count);
}

test "verify all directional variants implemented (2 total)" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const directional_variants = [_][]const u8{
        "rtl",
        "ltr",
    };

    for (directional_variants) |variant_name| {
        const variant = registry.get(variant_name);
        try testing.expect(variant != null);
        try testing.expect(variant.?.type == .directional);
        try testing.expect(variant.?.order >= 900 and variant.?.order < 1000);
    }

    var count: usize = 0;
    for (directional_variants) |_| count += 1;
    try testing.expectEqual(@as(usize, 2), count);
}

test "verify all responsive variants implemented (5 total)" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const responsive_variants = [_][]const u8{
        "sm",
        "md",
        "lg",
        "xl",
        "2xl",
    };

    for (responsive_variants) |variant_name| {
        const variant = registry.get(variant_name);
        try testing.expect(variant != null);
        try testing.expect(variant.?.type == .responsive);
        try testing.expect(variant.?.order >= 1000);
    }

    // Verify breakpoint values
    const sm = registry.get("sm").?;
    try testing.expect(std.mem.indexOf(u8, sm.css_selector, "640px") != null);

    const md = registry.get("md").?;
    try testing.expect(std.mem.indexOf(u8, md.css_selector, "768px") != null);

    const lg = registry.get("lg").?;
    try testing.expect(std.mem.indexOf(u8, lg.css_selector, "1024px") != null);

    const xl = registry.get("xl").?;
    try testing.expect(std.mem.indexOf(u8, xl.css_selector, "1280px") != null);

    const xxl = registry.get("2xl").?;
    try testing.expect(std.mem.indexOf(u8, xxl.css_selector, "1536px") != null);

    var count: usize = 0;
    for (responsive_variants) |_| count += 1;
    try testing.expectEqual(@as(usize, 5), count);
}

test "verify total variant count is 60+" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const total_count = registry.count();

    // Total: 29 + 9 + 2 + 9 + 1 + 2 + 8 + 3 + 2 + 5 = 70 variants
    try testing.expect(total_count >= 60);
    try testing.expectEqual(@as(usize, 70), total_count);
}

test "verify variant stacking order is properly implemented" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    // Get one variant from each category
    const hover = registry.get("hover").?; // Pseudo-class
    const before = registry.get("before").?; // Pseudo-element
    const open = registry.get("open").?; // State
    const dark = registry.get("dark").?; // Media query
    const print = registry.get("print").?; // Print
    const supports_grid = registry.get("supports-grid").?; // Supports
    const aria_checked = registry.get("aria-checked").?; // ARIA
    const data_active = registry.get("data-active").?; // Data
    const rtl = registry.get("rtl").?; // Directional
    const sm = registry.get("sm").?; // Responsive

    // Verify proper ordering
    try testing.expect(hover.order < before.order);
    try testing.expect(before.order < open.order);
    try testing.expect(open.order < dark.order);
    try testing.expect(dark.order < print.order);
    try testing.expect(print.order < supports_grid.order);
    try testing.expect(supports_grid.order < aria_checked.order);
    try testing.expect(aria_checked.order < data_active.order);
    try testing.expect(data_active.order < rtl.order);
    try testing.expect(rtl.order < sm.order);
}

test "verify variant CSS selectors are correct" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    // Test some key CSS selectors
    try testing.expectEqualStrings(":hover", registry.get("hover").?.css_selector);
    try testing.expectEqualStrings(":focus", registry.get("focus").?.css_selector);
    try testing.expectEqualStrings("::before", registry.get("before").?.css_selector);
    try testing.expectEqualStrings("::after", registry.get("after").?.css_selector);
    try testing.expectEqualStrings("[open]", registry.get("open").?.css_selector);
    try testing.expectEqualStrings("@media print", registry.get("print").?.css_selector);
    try testing.expectEqualStrings("[aria-checked=\"true\"]", registry.get("aria-checked").?.css_selector);
    try testing.expectEqualStrings("[dir=\"rtl\"]", registry.get("rtl").?.css_selector);
}

test "verify variant descriptions are present" {
    const allocator = testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const hover = registry.get("hover").?;
    try testing.expect(hover.description.len > 0);
    try testing.expectEqualStrings("On mouse hover", hover.description);

    const before = registry.get("before").?;
    try testing.expect(before.description.len > 0);
    try testing.expectEqualStrings("Before element", before.description);
}
