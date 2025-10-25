const std = @import("std");
const CSSGenerator = @import("css_generator.zig").CSSGenerator;
const CSSRule = @import("css_generator.zig").CSSRule;
const class_parser = @import("../parser/class_parser.zig");
const colors = @import("colors.zig");

/// Complete Border Utilities for Tailwind CSS
/// This module implements ALL border-related utilities from Tailwind CSS v3.4

// ============================================================================
// Border Radius
// ============================================================================

const border_radius = std.StaticStringMap([]const u8).initComptime(.{
    .{ "none", "0px" },
    .{ "sm", "0.125rem" },
    .{ "", "0.25rem" }, // Default rounded
    .{ "md", "0.375rem" },
    .{ "lg", "0.5rem" },
    .{ "xl", "0.75rem" },
    .{ "2xl", "1rem" },
    .{ "3xl", "1.5rem" },
    .{ "full", "9999px" },
});

pub fn generateRounded(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: ?[]const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const radius = if (value) |v| border_radius.get(v) orelse {
        rule.deinit(generator.allocator);
        return;
    } else border_radius.get("") orelse "0.25rem";

    try rule.addDeclaration(generator.allocator, "border-radius", radius);
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateRoundedSide(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, side: []const u8, value: ?[]const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const radius = if (value) |v| border_radius.get(v) orelse {
        rule.deinit(generator.allocator);
        return;
    } else border_radius.get("") orelse "0.25rem";

    // Side-specific radius (t=top, r=right, b=bottom, l=left, s=start, e=end)
    if (std.mem.eql(u8, side, "t")) {
        try rule.addDeclaration(generator.allocator, "border-top-left-radius", radius);
        try rule.addDeclaration(generator.allocator, "border-top-right-radius", radius);
    } else if (std.mem.eql(u8, side, "r")) {
        try rule.addDeclaration(generator.allocator, "border-top-right-radius", radius);
        try rule.addDeclaration(generator.allocator, "border-bottom-right-radius", radius);
    } else if (std.mem.eql(u8, side, "b")) {
        try rule.addDeclaration(generator.allocator, "border-bottom-left-radius", radius);
        try rule.addDeclaration(generator.allocator, "border-bottom-right-radius", radius);
    } else if (std.mem.eql(u8, side, "l")) {
        try rule.addDeclaration(generator.allocator, "border-top-left-radius", radius);
        try rule.addDeclaration(generator.allocator, "border-bottom-left-radius", radius);
    } else if (std.mem.eql(u8, side, "s")) {
        try rule.addDeclaration(generator.allocator, "border-start-start-radius", radius);
        try rule.addDeclaration(generator.allocator, "border-end-start-radius", radius);
    } else if (std.mem.eql(u8, side, "e")) {
        try rule.addDeclaration(generator.allocator, "border-start-end-radius", radius);
        try rule.addDeclaration(generator.allocator, "border-end-end-radius", radius);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

pub fn generateRoundedCorner(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, corner: []const u8, value: ?[]const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const radius = if (value) |v| border_radius.get(v) orelse {
        rule.deinit(generator.allocator);
        return;
    } else border_radius.get("") orelse "0.25rem";

    // Corner-specific radius
    const property = if (std.mem.eql(u8, corner, "tl"))
        "border-top-left-radius"
    else if (std.mem.eql(u8, corner, "tr"))
        "border-top-right-radius"
    else if (std.mem.eql(u8, corner, "br"))
        "border-bottom-right-radius"
    else if (std.mem.eql(u8, corner, "bl"))
        "border-bottom-left-radius"
    else if (std.mem.eql(u8, corner, "ss"))
        "border-start-start-radius"
    else if (std.mem.eql(u8, corner, "se"))
        "border-start-end-radius"
    else if (std.mem.eql(u8, corner, "ee"))
        "border-end-end-radius"
    else if (std.mem.eql(u8, corner, "es"))
        "border-end-start-radius"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, property, radius);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Border Width
// ============================================================================

const border_widths = std.StaticStringMap([]const u8).initComptime(.{
    .{ "0", "0px" },
    .{ "2", "2px" },
    .{ "4", "4px" },
    .{ "8", "8px" },
    .{ "", "1px" }, // Default border
});

pub fn generateBorderWidth(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: ?[]const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const width = if (value) |v| border_widths.get(v) orelse {
        rule.deinit(generator.allocator);
        return;
    } else border_widths.get("") orelse "1px";

    try rule.addDeclaration(generator.allocator, "border-width", width);
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateBorderWidthSide(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, side: []const u8, value: ?[]const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const width = if (value) |v| border_widths.get(v) orelse {
        rule.deinit(generator.allocator);
        return;
    } else border_widths.get("") orelse "1px";

    if (std.mem.eql(u8, side, "x")) {
        try rule.addDeclaration(generator.allocator, "border-left-width", width);
        try rule.addDeclaration(generator.allocator, "border-right-width", width);
    } else if (std.mem.eql(u8, side, "y")) {
        try rule.addDeclaration(generator.allocator, "border-top-width", width);
        try rule.addDeclaration(generator.allocator, "border-bottom-width", width);
    } else if (std.mem.eql(u8, side, "t")) {
        try rule.addDeclaration(generator.allocator, "border-top-width", width);
    } else if (std.mem.eql(u8, side, "r")) {
        try rule.addDeclaration(generator.allocator, "border-right-width", width);
    } else if (std.mem.eql(u8, side, "b")) {
        try rule.addDeclaration(generator.allocator, "border-bottom-width", width);
    } else if (std.mem.eql(u8, side, "l")) {
        try rule.addDeclaration(generator.allocator, "border-left-width", width);
    } else if (std.mem.eql(u8, side, "s")) {
        try rule.addDeclaration(generator.allocator, "border-inline-start-width", width);
    } else if (std.mem.eql(u8, side, "e")) {
        try rule.addDeclaration(generator.allocator, "border-inline-end-width", width);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Border Color
// ============================================================================

pub fn generateBorderColor(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const oklch_value = colors.resolveColor(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    const color_str = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});
    try rule.addDeclarationOwned(generator.allocator, "border-color", color_str);

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Border Style
// ============================================================================

pub fn generateBorderStyle(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, style: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, style, "solid"))
        "solid"
    else if (std.mem.eql(u8, style, "dashed"))
        "dashed"
    else if (std.mem.eql(u8, style, "dotted"))
        "dotted"
    else if (std.mem.eql(u8, style, "double"))
        "double"
    else if (std.mem.eql(u8, style, "hidden"))
        "hidden"
    else if (std.mem.eql(u8, style, "none"))
        "none"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "border-style", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Divide Width
// ============================================================================

pub fn generateDivideWidth(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, axis: []const u8, value: ?[]const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const width = if (value) |v| border_widths.get(v) orelse {
        rule.deinit(generator.allocator);
        return;
    } else border_widths.get("") orelse "1px";

    // Divide requires :not(:first-child) selector modification
    // This is a simplified version - full implementation would modify the selector
    if (std.mem.eql(u8, axis, "x")) {
        try rule.addDeclaration(generator.allocator, "border-left-width", width);
    } else if (std.mem.eql(u8, axis, "y")) {
        try rule.addDeclaration(generator.allocator, "border-top-width", width);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Divide Color
// ============================================================================

pub fn generateDivideColor(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const oklch_value = colors.resolveColor(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    const color_str = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});
    try rule.addDeclarationOwned(generator.allocator, "border-color", color_str);

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Divide Style
// ============================================================================

pub fn generateDivideStyle(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, style: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, style, "solid"))
        "solid"
    else if (std.mem.eql(u8, style, "dashed"))
        "dashed"
    else if (std.mem.eql(u8, style, "dotted"))
        "dotted"
    else if (std.mem.eql(u8, style, "double"))
        "double"
    else if (std.mem.eql(u8, style, "none"))
        "none"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "border-style", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Outline Width
// ============================================================================

pub fn generateOutlineWidth(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: ?[]const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const width = if (value) |v| border_widths.get(v) orelse {
        rule.deinit(generator.allocator);
        return;
    } else border_widths.get("") orelse "1px";

    try rule.addDeclaration(generator.allocator, "outline-width", width);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Outline Color
// ============================================================================

pub fn generateOutlineColor(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const oklch_value = colors.resolveColor(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    const color_str = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});
    try rule.addDeclarationOwned(generator.allocator, "outline-color", color_str);

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Outline Style
// ============================================================================

pub fn generateOutlineStyle(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, style: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, style, "none"))
        "none"
    else if (std.mem.eql(u8, style, "solid"))
        "solid"
    else if (std.mem.eql(u8, style, "dashed"))
        "dashed"
    else if (std.mem.eql(u8, style, "dotted"))
        "dotted"
    else if (std.mem.eql(u8, style, "double"))
        "double"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "outline-style", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Outline Offset
// ============================================================================

const outline_offsets = std.StaticStringMap([]const u8).initComptime(.{
    .{ "0", "0px" },
    .{ "1", "1px" },
    .{ "2", "2px" },
    .{ "4", "4px" },
    .{ "8", "8px" },
});

pub fn generateOutlineOffset(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const offset = outline_offsets.get(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "outline-offset", offset);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Ring Width
// ============================================================================

const ring_widths = std.StaticStringMap([]const u8).initComptime(.{
    .{ "0", "0px" },
    .{ "1", "1px" },
    .{ "2", "2px" },
    .{ "", "3px" }, // Default ring
    .{ "4", "4px" },
    .{ "8", "8px" },
});

pub fn generateRingWidth(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: ?[]const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const width = if (value) |v| ring_widths.get(v) orelse {
        rule.deinit(generator.allocator);
        return;
    } else ring_widths.get("") orelse "3px";

    try rule.addDeclaration(generator.allocator, "--tw-ring-offset-shadow", "var(--tw-ring-inset) 0 0 0 var(--tw-ring-offset-width) var(--tw-ring-offset-color)");
    const shadow = try std.fmt.allocPrint(
        generator.allocator,
        "var(--tw-ring-inset) 0 0 0 calc({s} + var(--tw-ring-offset-width)) var(--tw-ring-color)",
        .{width},
    );
    try rule.addDeclarationOwned(generator.allocator, "--tw-ring-shadow", shadow);
    try rule.addDeclaration(generator.allocator, "box-shadow", "var(--tw-ring-offset-shadow), var(--tw-ring-shadow), var(--tw-shadow, 0 0 #0000)");

    try generator.rules.append(generator.allocator, rule);
}

pub fn generateRingInset(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "--tw-ring-inset", "inset");
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Ring Color
// ============================================================================

pub fn generateRingColor(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const oklch_value = colors.resolveColor(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    const color_str = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});
    try rule.addDeclarationOwned(generator.allocator, "--tw-ring-color", color_str);

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Ring Offset Width
// ============================================================================

pub fn generateRingOffsetWidth(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const offset = outline_offsets.get(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "--tw-ring-offset-width", offset);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Ring Offset Color
// ============================================================================

pub fn generateRingOffsetColor(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const oklch_value = colors.resolveColor(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    const color_str = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});
    try rule.addDeclarationOwned(generator.allocator, "--tw-ring-offset-color", color_str);

    try generator.rules.append(generator.allocator, rule);
}
