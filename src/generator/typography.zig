const std = @import("std");
const CSSGenerator = @import("css_generator.zig").CSSGenerator;
const CSSRule = @import("css_generator.zig").CSSRule;
const class_parser = @import("../parser/class_parser.zig");
const colors = @import("colors.zig");

/// Complete Typography Utilities for Tailwind CSS
/// This module implements ALL typography-related utilities from Tailwind CSS v3.4

// ============================================================================
// Font Family
// ============================================================================

const font_families = std.StaticStringMap([]const u8).initComptime(.{
    .{ "sans", "ui-sans-serif, system-ui, sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\", \"Noto Color Emoji\"" },
    .{ "serif", "ui-serif, Georgia, Cambria, \"Times New Roman\", Times, serif" },
    .{ "mono", "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, \"Liberation Mono\", \"Courier New\", monospace" },
});

pub fn generateFontFamily(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    if (font_families.get(value)) |family| {
        try rule.addDeclaration(generator.allocator, "font-family", family);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Font Size
// ============================================================================

const FontSize = struct { size: []const u8, line_height: []const u8 };

fn getFontSize(value: []const u8) ?FontSize {
    if (std.mem.eql(u8, value, "xs")) return FontSize{ .size = "0.75rem", .line_height = "1rem" };
    if (std.mem.eql(u8, value, "sm")) return FontSize{ .size = "0.875rem", .line_height = "1.25rem" };
    if (std.mem.eql(u8, value, "base")) return FontSize{ .size = "1rem", .line_height = "1.5rem" };
    if (std.mem.eql(u8, value, "lg")) return FontSize{ .size = "1.125rem", .line_height = "1.75rem" };
    if (std.mem.eql(u8, value, "xl")) return FontSize{ .size = "1.25rem", .line_height = "1.75rem" };
    if (std.mem.eql(u8, value, "2xl")) return FontSize{ .size = "1.5rem", .line_height = "2rem" };
    if (std.mem.eql(u8, value, "3xl")) return FontSize{ .size = "1.875rem", .line_height = "2.25rem" };
    if (std.mem.eql(u8, value, "4xl")) return FontSize{ .size = "2.25rem", .line_height = "2.5rem" };
    if (std.mem.eql(u8, value, "5xl")) return FontSize{ .size = "3rem", .line_height = "1" };
    if (std.mem.eql(u8, value, "6xl")) return FontSize{ .size = "3.75rem", .line_height = "1" };
    if (std.mem.eql(u8, value, "7xl")) return FontSize{ .size = "4.5rem", .line_height = "1" };
    if (std.mem.eql(u8, value, "8xl")) return FontSize{ .size = "6rem", .line_height = "1" };
    if (std.mem.eql(u8, value, "9xl")) return FontSize{ .size = "8rem", .line_height = "1" };
    return null;
}

pub fn generateFontSize(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    if (getFontSize(value)) |size_info| {
        try rule.addDeclaration(generator.allocator, "font-size", size_info.size);
        try rule.addDeclaration(generator.allocator, "line-height", size_info.line_height);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Font Smoothing
// ============================================================================

pub fn generateAntialiased(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "-webkit-font-smoothing", "antialiased");
    try rule.addDeclaration(generator.allocator, "-moz-osx-font-smoothing", "grayscale");

    try generator.rules.append(generator.allocator, rule);
}

pub fn generateSubpixelAntialiased(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "-webkit-font-smoothing", "auto");
    try rule.addDeclaration(generator.allocator, "-moz-osx-font-smoothing", "auto");

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Font Style
// ============================================================================

pub fn generateItalic(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "font-style", "italic");
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateNotItalic(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "font-style", "normal");
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Font Weight
// ============================================================================

const font_weights = std.StaticStringMap([]const u8).initComptime(.{
    .{ "thin", "100" },
    .{ "extralight", "200" },
    .{ "light", "300" },
    .{ "normal", "400" },
    .{ "medium", "500" },
    .{ "semibold", "600" },
    .{ "bold", "700" },
    .{ "extrabold", "800" },
    .{ "black", "900" },
});

pub fn generateFontWeight(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    if (font_weights.get(value)) |weight| {
        try rule.addDeclaration(generator.allocator, "font-weight", weight);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Font Variant Numeric
// ============================================================================

pub fn generateFontVariantNumeric(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, variant: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, variant, "normal-nums"))
        "normal"
    else if (std.mem.eql(u8, variant, "ordinal"))
        "ordinal"
    else if (std.mem.eql(u8, variant, "slashed-zero"))
        "slashed-zero"
    else if (std.mem.eql(u8, variant, "lining-nums"))
        "lining-nums"
    else if (std.mem.eql(u8, variant, "oldstyle-nums"))
        "oldstyle-nums"
    else if (std.mem.eql(u8, variant, "proportional-nums"))
        "proportional-nums"
    else if (std.mem.eql(u8, variant, "tabular-nums"))
        "tabular-nums"
    else if (std.mem.eql(u8, variant, "diagonal-fractions"))
        "diagonal-fractions"
    else if (std.mem.eql(u8, variant, "stacked-fractions"))
        "stacked-fractions"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "font-variant-numeric", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Letter Spacing (Tracking)
// ============================================================================

const letter_spacing = std.StaticStringMap([]const u8).initComptime(.{
    .{ "tighter", "-0.05em" },
    .{ "tight", "-0.025em" },
    .{ "normal", "0em" },
    .{ "wide", "0.025em" },
    .{ "wider", "0.05em" },
    .{ "widest", "0.1em" },
});

pub fn generateTracking(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    if (letter_spacing.get(value)) |spacing| {
        try rule.addDeclaration(generator.allocator, "letter-spacing", spacing);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Line Clamp
// ============================================================================

pub fn generateLineClamp(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    if (std.mem.eql(u8, value, "none")) {
        try rule.addDeclaration(generator.allocator, "overflow", "visible");
        try rule.addDeclaration(generator.allocator, "display", "block");
        try rule.addDeclaration(generator.allocator, "-webkit-box-orient", "horizontal");
        try rule.addDeclaration(generator.allocator, "-webkit-line-clamp", "none");
    } else {
        try rule.addDeclaration(generator.allocator, "overflow", "hidden");
        try rule.addDeclaration(generator.allocator, "display", "-webkit-box");
        try rule.addDeclaration(generator.allocator, "-webkit-box-orient", "vertical");
        try rule.addDeclaration(generator.allocator, "-webkit-line-clamp", value);
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Line Height (Leading)
// ============================================================================

const line_heights = std.StaticStringMap([]const u8).initComptime(.{
    .{ "none", "1" },
    .{ "tight", "1.25" },
    .{ "snug", "1.375" },
    .{ "normal", "1.5" },
    .{ "relaxed", "1.625" },
    .{ "loose", "2" },
    .{ "3", ".75rem" },
    .{ "4", "1rem" },
    .{ "5", "1.25rem" },
    .{ "6", "1.5rem" },
    .{ "7", "1.75rem" },
    .{ "8", "2rem" },
    .{ "9", "2.25rem" },
    .{ "10", "2.5rem" },
});

pub fn generateLeading(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    if (line_heights.get(value)) |height| {
        try rule.addDeclaration(generator.allocator, "line-height", height);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// List Style Type
// ============================================================================

const list_styles = std.StaticStringMap([]const u8).initComptime(.{
    .{ "none", "none" },
    .{ "disc", "disc" },
    .{ "decimal", "decimal" },
});

pub fn generateListStyle(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    if (list_styles.get(value)) |style| {
        try rule.addDeclaration(generator.allocator, "list-style-type", style);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// List Style Position
// ============================================================================

pub fn generateListInside(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "list-style-position", "inside");
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateListOutside(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "list-style-position", "outside");
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Text Alignment
// ============================================================================

pub fn generateTextAlign(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, alignment: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, alignment, "left"))
        "left"
    else if (std.mem.eql(u8, alignment, "center"))
        "center"
    else if (std.mem.eql(u8, alignment, "right"))
        "right"
    else if (std.mem.eql(u8, alignment, "justify"))
        "justify"
    else if (std.mem.eql(u8, alignment, "start"))
        "start"
    else if (std.mem.eql(u8, alignment, "end"))
        "end"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "text-align", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Text Color
// ============================================================================

pub fn generateTextColor(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const oklch_value = colors.resolveColor(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    const color_str = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});
    try rule.addDeclarationOwned(generator.allocator, "color", color_str);

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Text Decoration
// ============================================================================

pub fn generateUnderline(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "text-decoration-line", "underline");
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateOverline(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "text-decoration-line", "overline");
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateLineThrough(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "text-decoration-line", "line-through");
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateNoUnderline(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "text-decoration-line", "none");
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Text Decoration Color
// ============================================================================

pub fn generateDecorationColor(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const oklch_value = colors.resolveColor(value) orelse {
        rule.deinit(generator.allocator);
        return;
    };

    const color_str = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});
    try rule.addDeclarationOwned(generator.allocator, "text-decoration-color", color_str);

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Text Decoration Style
// ============================================================================

pub fn generateDecorationStyle(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, style: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, style, "solid"))
        "solid"
    else if (std.mem.eql(u8, style, "double"))
        "double"
    else if (std.mem.eql(u8, style, "dotted"))
        "dotted"
    else if (std.mem.eql(u8, style, "dashed"))
        "dashed"
    else if (std.mem.eql(u8, style, "wavy"))
        "wavy"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "text-decoration-style", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Text Decoration Thickness
// ============================================================================

const decoration_thickness = std.StaticStringMap([]const u8).initComptime(.{
    .{ "auto", "auto" },
    .{ "from-font", "from-font" },
    .{ "0", "0px" },
    .{ "1", "1px" },
    .{ "2", "2px" },
    .{ "4", "4px" },
    .{ "8", "8px" },
});

pub fn generateDecorationThickness(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    if (decoration_thickness.get(value)) |thickness| {
        try rule.addDeclaration(generator.allocator, "text-decoration-thickness", thickness);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Text Underline Offset
// ============================================================================

const underline_offset = std.StaticStringMap([]const u8).initComptime(.{
    .{ "auto", "auto" },
    .{ "0", "0px" },
    .{ "1", "1px" },
    .{ "2", "2px" },
    .{ "4", "4px" },
    .{ "8", "8px" },
});

pub fn generateUnderlineOffset(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    if (underline_offset.get(value)) |offset| {
        try rule.addDeclaration(generator.allocator, "text-underline-offset", offset);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Text Transform
// ============================================================================

pub fn generateUppercase(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "text-transform", "uppercase");
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateLowercase(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "text-transform", "lowercase");
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateCapitalize(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "text-transform", "capitalize");
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateNormalCase(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "text-transform", "none");
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Text Overflow
// ============================================================================

pub fn generateTruncate(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "overflow", "hidden");
    try rule.addDeclaration(generator.allocator, "text-overflow", "ellipsis");
    try rule.addDeclaration(generator.allocator, "white-space", "nowrap");

    try generator.rules.append(generator.allocator, rule);
}

pub fn generateTextEllipsis(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "text-overflow", "ellipsis");
    try generator.rules.append(generator.allocator, rule);
}

pub fn generateTextClip(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "text-overflow", "clip");
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Text Wrap
// ============================================================================

pub fn generateTextWrap(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, mode: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, mode, "wrap"))
        "wrap"
    else if (std.mem.eql(u8, mode, "nowrap"))
        "nowrap"
    else if (std.mem.eql(u8, mode, "balance"))
        "balance"
    else if (std.mem.eql(u8, mode, "pretty"))
        "pretty"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "text-wrap", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Text Indent
// ============================================================================

const spacing_scale = @import("spacing.zig").spacing_scale;

pub fn generateIndent(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, value: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    if (spacing_scale.get(value)) |size| {
        try rule.addDeclaration(generator.allocator, "text-indent", size);
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Vertical Align
// ============================================================================

pub fn generateAlign(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, alignment: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, alignment, "baseline"))
        "baseline"
    else if (std.mem.eql(u8, alignment, "top"))
        "top"
    else if (std.mem.eql(u8, alignment, "middle"))
        "middle"
    else if (std.mem.eql(u8, alignment, "bottom"))
        "bottom"
    else if (std.mem.eql(u8, alignment, "text-top"))
        "text-top"
    else if (std.mem.eql(u8, alignment, "text-bottom"))
        "text-bottom"
    else if (std.mem.eql(u8, alignment, "sub"))
        "sub"
    else if (std.mem.eql(u8, alignment, "super"))
        "super"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "vertical-align", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Whitespace
// ============================================================================

pub fn generateWhitespace(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, mode: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, mode, "normal"))
        "normal"
    else if (std.mem.eql(u8, mode, "nowrap"))
        "nowrap"
    else if (std.mem.eql(u8, mode, "pre"))
        "pre"
    else if (std.mem.eql(u8, mode, "pre-line"))
        "pre-line"
    else if (std.mem.eql(u8, mode, "pre-wrap"))
        "pre-wrap"
    else if (std.mem.eql(u8, mode, "break-spaces"))
        "break-spaces"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "white-space", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Word Break
// ============================================================================

pub fn generateBreak(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, mode: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    if (std.mem.eql(u8, mode, "normal")) {
        try rule.addDeclaration(generator.allocator, "overflow-wrap", "normal");
        try rule.addDeclaration(generator.allocator, "word-break", "normal");
    } else if (std.mem.eql(u8, mode, "words")) {
        try rule.addDeclaration(generator.allocator, "overflow-wrap", "break-word");
    } else if (std.mem.eql(u8, mode, "all")) {
        try rule.addDeclaration(generator.allocator, "word-break", "break-all");
    } else if (std.mem.eql(u8, mode, "keep")) {
        try rule.addDeclaration(generator.allocator, "word-break", "keep-all");
    } else {
        rule.deinit(generator.allocator);
        return;
    }

    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Hyphens
// ============================================================================

pub fn generateHyphens(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass, mode: []const u8) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const value = if (std.mem.eql(u8, mode, "none"))
        "none"
    else if (std.mem.eql(u8, mode, "manual"))
        "manual"
    else if (std.mem.eql(u8, mode, "auto"))
        "auto"
    else {
        rule.deinit(generator.allocator);
        return;
    };

    try rule.addDeclaration(generator.allocator, "hyphens", value);
    try generator.rules.append(generator.allocator, rule);
}

// ============================================================================
// Content
// ============================================================================

pub fn generateContentNone(generator: *CSSGenerator, parsed: *const class_parser.ParsedClass) !void {
    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclaration(generator.allocator, "content", "none");
    try generator.rules.append(generator.allocator, rule);
}
