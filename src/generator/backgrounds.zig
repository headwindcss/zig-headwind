const std = @import("std");
const CSSGenerator = @import("css_generator.zig").CSSGenerator;
const CSSRule = @import("css_generator.zig").CSSRule;
const class_parser = @import("../parser/class_parser.zig");
const colors = @import("colors.zig");

/// Complete Background Utilities for Tailwind CSS
/// This module implements ALL background-related utilities from Tailwind CSS v3.4

// ============================================================================
// Background Attachment
// ============================================================================

pub fn generateBgAttachment(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const attachment = if (std.mem.eql(u8, value, "fixed"))
        "fixed"
    else if (std.mem.eql(u8, value, "local"))
        "local"
    else if (std.mem.eql(u8, value, "scroll"))
        "scroll"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "background-attachment", attachment);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Background Clip
// ============================================================================

pub fn generateBgClip(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const clip = if (std.mem.eql(u8, value, "border"))
        "border-box"
    else if (std.mem.eql(u8, value, "padding"))
        "padding-box"
    else if (std.mem.eql(u8, value, "content"))
        "content-box"
    else if (std.mem.eql(u8, value, "text"))
        "text"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "background-clip", clip);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Background Color
// ============================================================================

pub fn generateBgColor(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const oklch_value = colors.resolveColor(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    const color_str = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});
    try rule.addDeclarationOwned(generator.allocator, "background-color", color_str);

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Background Origin
// ============================================================================

pub fn generateBgOrigin(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const origin = if (std.mem.eql(u8, value, "border"))
        "border-box"
    else if (std.mem.eql(u8, value, "padding"))
        "padding-box"
    else if (std.mem.eql(u8, value, "content"))
        "content-box"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "background-origin", origin);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Background Position
// ============================================================================

pub fn generateBgPosition(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, position: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, position, "bottom"))
        "bottom"
    else if (std.mem.eql(u8, position, "center"))
        "center"
    else if (std.mem.eql(u8, position, "left"))
        "left"
    else if (std.mem.eql(u8, position, "left-bottom"))
        "left bottom"
    else if (std.mem.eql(u8, position, "left-top"))
        "left top"
    else if (std.mem.eql(u8, position, "right"))
        "right"
    else if (std.mem.eql(u8, position, "right-bottom"))
        "right bottom"
    else if (std.mem.eql(u8, position, "right-top"))
        "right top"
    else if (std.mem.eql(u8, position, "top"))
        "top"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "background-position", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Background Repeat
// ============================================================================

pub fn generateBgRepeat(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, repeat: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, repeat, "repeat"))
        "repeat"
    else if (std.mem.eql(u8, repeat, "no-repeat"))
        "no-repeat"
    else if (std.mem.eql(u8, repeat, "repeat-x"))
        "repeat-x"
    else if (std.mem.eql(u8, repeat, "repeat-y"))
        "repeat-y"
    else if (std.mem.eql(u8, repeat, "repeat-round"))
        "round"
    else if (std.mem.eql(u8, repeat, "repeat-space"))
        "space"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "background-repeat", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Background Size
// ============================================================================

pub fn generateBgSize(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, size: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, size, "auto"))
        "auto"
    else if (std.mem.eql(u8, size, "cover"))
        "cover"
    else if (std.mem.eql(u8, size, "contain"))
        "contain"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "background-size", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Background Image
// ============================================================================

pub fn generateBgNone(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "background-image", "none");
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateBgGradient(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, direction: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const gradient = if (std.mem.eql(u8, direction, "to-t"))
        "linear-gradient(to top, var(--tw-gradient-stops))"
    else if (std.mem.eql(u8, direction, "to-tr"))
        "linear-gradient(to top right, var(--tw-gradient-stops))"
    else if (std.mem.eql(u8, direction, "to-r"))
        "linear-gradient(to right, var(--tw-gradient-stops))"
    else if (std.mem.eql(u8, direction, "to-br"))
        "linear-gradient(to bottom right, var(--tw-gradient-stops))"
    else if (std.mem.eql(u8, direction, "to-b"))
        "linear-gradient(to bottom, var(--tw-gradient-stops))"
    else if (std.mem.eql(u8, direction, "to-bl"))
        "linear-gradient(to bottom left, var(--tw-gradient-stops))"
    else if (std.mem.eql(u8, direction, "to-l"))
        "linear-gradient(to left, var(--tw-gradient-stops))"
    else if (std.mem.eql(u8, direction, "to-tl"))
        "linear-gradient(to top left, var(--tw-gradient-stops))"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "background-image", gradient);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Gradient Color Stops
// ============================================================================

pub fn generateGradientFrom(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const oklch_value = colors.resolveColor(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    const from_color = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});
    try rule.addDeclarationOwned(generator.allocator, "--tw-gradient-from", from_color);

    const stops = try std.fmt.allocPrint(
        generator.allocator,
        "var(--tw-gradient-from), var(--tw-gradient-to, oklch({s} / 0))",
        .{oklch_value},
    );
    try rule.addDeclarationOwned(generator.allocator, "--tw-gradient-stops", stops);

    try generator.rules.append(generator.allocator, rule);
}

pub fn generateGradientVia(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const oklch_value = colors.resolveColor(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    const via_color = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});
    try rule.addDeclarationOwned(generator.allocator, "--tw-gradient-via", via_color);

    const stops = try std.fmt.allocPrint(
        generator.allocator,
        "var(--tw-gradient-from), var(--tw-gradient-via), var(--tw-gradient-to, oklch({s} / 0))",
        .{oklch_value},
    );
    try rule.addDeclarationOwned(generator.allocator, "--tw-gradient-stops", stops);

    try generator.rules.append(generator.allocator, rule);
}

pub fn generateGradientTo(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const oklch_value = colors.resolveColor(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    const to_color = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});
    try rule.addDeclarationOwned(generator.allocator, "--tw-gradient-to", to_color);

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Gradient Color Stop Positions (simplified)
// ============================================================================

pub fn generateGradientFromPosition(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, position: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const pos = try std.fmt.allocPrint(generator.allocator, "{s}%", .{position});
    try rule.addDeclarationOwned(generator.allocator, "--tw-gradient-from-position", pos);

    try generator.rules.append(generator.allocator, rule);
}

pub fn generateGradientViaPosition(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, position: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const pos = try std.fmt.allocPrint(generator.allocator, "{s}%", .{position});
    try rule.addDeclarationOwned(generator.allocator, "--tw-gradient-via-position", pos);

    try generator.rules.append(generator.allocator, rule);
}

pub fn generateGradientToPosition(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, position: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const pos = try std.fmt.allocPrint(generator.allocator, "{s}%", .{position});
    try rule.addDeclarationOwned(generator.allocator, "--tw-gradient-to-position", pos);

    try generator.rules.append(generator.allocator, rule);
}
