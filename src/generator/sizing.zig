const std = @import("std");
const CSSGenerator = @import("css_generator.zig").CSSGenerator;
const CSSRule = @import("css_generator.zig").CSSRule;
const class_parser = @import("../parser/class_parser.zig");
const spacing = @import("spacing.zig");

/// Complete Sizing Utilities for Tailwind CSS
/// This module implements ALL sizing-related utilities from Tailwind CSS v3.4

// ============================================================================
// Width Utilities
// ============================================================================

const width_special = std.StaticStringMap([]const u8).initComptime(.{
    .{ "auto", "auto" },
    .{ "px", "1px" },
    .{ "full", "100%" },
    .{ "screen", "100vw" },
    .{ "svw", "100svw" },
    .{ "lvw", "100lvw" },
    .{ "dvw", "100dvw" },
    .{ "min", "min-content" },
    .{ "max", "max-content" },
    .{ "fit", "fit-content" },
});

const width_fractions = std.StaticStringMap([]const u8).initComptime(.{
    .{ "1/2", "50%" },
    .{ "1/3", "33.333333%" },
    .{ "2/3", "66.666667%" },
    .{ "1/4", "25%" },
    .{ "2/4", "50%" },
    .{ "3/4", "75%" },
    .{ "1/5", "20%" },
    .{ "2/5", "40%" },
    .{ "3/5", "60%" },
    .{ "4/5", "80%" },
    .{ "1/6", "16.666667%" },
    .{ "2/6", "33.333333%" },
    .{ "3/6", "50%" },
    .{ "4/6", "66.666667%" },
    .{ "5/6", "83.333333%" },
    .{ "1/12", "8.333333%" },
    .{ "2/12", "16.666667%" },
    .{ "3/12", "25%" },
    .{ "4/12", "33.333333%" },
    .{ "5/12", "41.666667%" },
    .{ "6/12", "50%" },
    .{ "7/12", "58.333333%" },
    .{ "8/12", "66.666667%" },
    .{ "9/12", "75%" },
    .{ "10/12", "83.333333%" },
    .{ "11/12", "91.666667%" },
});

pub fn generateWidth(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    // Handle arbitrary values first
    const width_value = if (parsed.is_arbitrary and parsed.arbitrary_value != null)
        parsed.arbitrary_value.?
    else if (width_special.get(value)) |special|
        special
    else if (width_fractions.get(value)) |fraction|
        fraction
    else if (spacing.spacing_scale.get(value)) |size|
        size
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "width", width_value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Min-Width Utilities
// ============================================================================

const min_width_special = std.StaticStringMap([]const u8).initComptime(.{
    .{ "full", "100%" },
    .{ "min", "min-content" },
    .{ "max", "max-content" },
    .{ "fit", "fit-content" },
});

pub fn generateMinWidth(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const min_width_value = if (min_width_special.get(value)) |special|
        special
    else if (spacing.spacing_scale.get(value)) |size|
        size
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "min-width", min_width_value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Max-Width Utilities
// ============================================================================

const max_width_sizes = std.StaticStringMap([]const u8).initComptime(.{
    .{ "none", "none" },
    .{ "0", "0rem" },
    .{ "xs", "20rem" },
    .{ "sm", "24rem" },
    .{ "md", "28rem" },
    .{ "lg", "32rem" },
    .{ "xl", "36rem" },
    .{ "2xl", "42rem" },
    .{ "3xl", "48rem" },
    .{ "4xl", "56rem" },
    .{ "5xl", "64rem" },
    .{ "6xl", "72rem" },
    .{ "7xl", "80rem" },
    .{ "full", "100%" },
    .{ "min", "min-content" },
    .{ "max", "max-content" },
    .{ "fit", "fit-content" },
    .{ "prose", "65ch" },
    .{ "screen-sm", "640px" },
    .{ "screen-md", "768px" },
    .{ "screen-lg", "1024px" },
    .{ "screen-xl", "1280px" },
    .{ "screen-2xl", "1536px" },
});

pub fn generateMaxWidth(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const max_width_value = max_width_sizes.get(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "max-width", max_width_value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Height Utilities
// ============================================================================

const height_special = std.StaticStringMap([]const u8).initComptime(.{
    .{ "auto", "auto" },
    .{ "px", "1px" },
    .{ "full", "100%" },
    .{ "screen", "100vh" },
    .{ "svh", "100svh" },
    .{ "lvh", "100lvh" },
    .{ "dvh", "100dvh" },
    .{ "min", "min-content" },
    .{ "max", "max-content" },
    .{ "fit", "fit-content" },
});

pub fn generateHeight(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const height_value = if (height_special.get(value)) |special|
        special
    else if (width_fractions.get(value)) |fraction|
        fraction
    else if (spacing.spacing_scale.get(value)) |size|
        size
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "height", height_value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Min-Height Utilities
// ============================================================================

const min_height_special = std.StaticStringMap([]const u8).initComptime(.{
    .{ "full", "100%" },
    .{ "screen", "100vh" },
    .{ "svh", "100svh" },
    .{ "lvh", "100lvh" },
    .{ "dvh", "100dvh" },
    .{ "min", "min-content" },
    .{ "max", "max-content" },
    .{ "fit", "fit-content" },
});

pub fn generateMinHeight(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const min_height_value = if (min_height_special.get(value)) |special|
        special
    else if (spacing.spacing_scale.get(value)) |size|
        size
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "min-height", min_height_value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Max-Height Utilities
// ============================================================================

const max_height_special = std.StaticStringMap([]const u8).initComptime(.{
    .{ "none", "none" },
    .{ "full", "100%" },
    .{ "screen", "100vh" },
    .{ "svh", "100svh" },
    .{ "lvh", "100lvh" },
    .{ "dvh", "100dvh" },
    .{ "min", "min-content" },
    .{ "max", "max-content" },
    .{ "fit", "fit-content" },
});

pub fn generateMaxHeight(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const max_height_value = if (max_height_special.get(value)) |special|
        special
    else if (spacing.spacing_scale.get(value)) |size|
        size
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "max-height", max_height_value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Size Utilities (width + height together)
// ============================================================================

const size_special = std.StaticStringMap([]const u8).initComptime(.{
    .{ "auto", "auto" },
    .{ "px", "1px" },
    .{ "full", "100%" },
    .{ "min", "min-content" },
    .{ "max", "max-content" },
    .{ "fit", "fit-content" },
});

pub fn generateSize(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const size_value = if (size_special.get(value)) |special|
        special
    else if (width_fractions.get(value)) |fraction|
        fraction
    else if (spacing.spacing_scale.get(value)) |size|
        size
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "width", size_value);
    try rule.addDeclaration(generator.allocator, "height", size_value);

    try generator.rules.append(generator.allocator, rule);
}
