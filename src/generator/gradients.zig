const std = @import("std");
const CSSGenerator = @import("css_generator.zig").CSSGenerator;
const CSSRule = @import("css_generator.zig").CSSRule;
const class_parser = @import("../parser/class_parser.zig");

/// Gradient directions for linear gradients
const gradient_directions = std.StaticStringMap([]const u8).initComptime(.{
    .{ "to-t", "to top" },
    .{ "to-tr", "to top right" },
    .{ "to-r", "to right" },
    .{ "to-br", "to bottom right" },
    .{ "to-b", "to bottom" },
    .{ "to-bl", "to bottom left" },
    .{ "to-l", "to left" },
    .{ "to-tl", "to top left" },
});

/// Generate background gradient utilities (bg-gradient-*)
pub fn generateBackgroundGradient(
    generator: *CSSGenerator,
    parsed: *const class_parser.ParsedClass,
    value: ?[]const u8,
) !void {
    if (value == null) return;

    const direction = gradient_directions.get(value.?) orelse return;

    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);
    try rule.addDeclarationOwned(generator.allocator, "background-image", try std.fmt.allocPrint(
        generator.allocator,
        "linear-gradient({s}, var(--hw-gradient-stops))",
        .{direction},
    ));
    try generator.rules.append(generator.allocator, rule);
}

/// Generate gradient from color (from-*)
pub fn generateGradientFrom(
    generator: *CSSGenerator,
    parsed: *const class_parser.ParsedClass,
    value: ?[]const u8,
) !void {
    if (value == null) return;

    const colors_module = @import("colors.zig");
    const oklch_value = colors_module.resolveColor(value.?) orelse return;

    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const from_color = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});

    // Set CSS variable for gradient start
    try rule.addDeclarationOwned(
        generator.allocator,
        "--hw-gradient-from",
        from_color,
    );
    try rule.addDeclaration(
        generator.allocator,
        "--hw-gradient-to",
        "transparent",
    );
    try rule.addDeclaration(
        generator.allocator,
        "--hw-gradient-stops",
        "var(--hw-gradient-from), var(--hw-gradient-to)",
    );

    try generator.rules.append(generator.allocator, rule);
}

/// Generate gradient via color (via-*)
pub fn generateGradientVia(
    generator: *CSSGenerator,
    parsed: *const class_parser.ParsedClass,
    value: ?[]const u8,
) !void {
    if (value == null) return;

    const colors_module = @import("colors.zig");
    const oklch_value = colors_module.resolveColor(value.?) orelse return;

    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    try rule.addDeclarationOwned(
        generator.allocator,
        "--hw-gradient-stops",
        try std.fmt.allocPrint(
            generator.allocator,
            "var(--hw-gradient-from), oklch({s}), var(--hw-gradient-to)",
            .{oklch_value},
        ),
    );

    try generator.rules.append(generator.allocator, rule);
}

/// Generate gradient to color (to-*)
pub fn generateGradientTo(
    generator: *CSSGenerator,
    parsed: *const class_parser.ParsedClass,
    value: ?[]const u8,
) !void {
    if (value == null) return;

    const colors_module = @import("colors.zig");
    const oklch_value = colors_module.resolveColor(value.?) orelse return;

    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);

    const to_color = try std.fmt.allocPrint(generator.allocator, "oklch({s})", .{oklch_value});

    try rule.addDeclarationOwned(
        generator.allocator,
        "--hw-gradient-to",
        to_color,
    );

    try generator.rules.append(generator.allocator, rule);
}

/// Generate radial gradient utilities
pub fn generateRadialGradient(
    generator: *CSSGenerator,
    parsed: *const class_parser.ParsedClass,
    value: ?[]const u8,
) !void {
    _ = value;

    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);
    try rule.addDeclaration(
        generator.allocator,
        "background-image",
        "radial-gradient(circle, var(--hw-gradient-stops))",
    );
    try generator.rules.append(generator.allocator, rule);
}

/// Generate conic gradient utilities
pub fn generateConicGradient(
    generator: *CSSGenerator,
    parsed: *const class_parser.ParsedClass,
    value: ?[]const u8,
) !void {
    _ = value;

    var rule = try generator.createRule(parsed);
    errdefer rule.deinit(generator.allocator);
    try rule.addDeclaration(
        generator.allocator,
        "background-image",
        "conic-gradient(from 0deg, var(--hw-gradient-stops))",
    );
    try generator.rules.append(generator.allocator, rule);
}
