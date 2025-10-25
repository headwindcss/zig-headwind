const std = @import("std");

/// Validates CSS custom property (variable) syntax
/// Supports:
/// - var(--name)
/// - var(--name, fallback)
/// - var(--name-with-dashes)
/// - var(--name_with_underscores)
pub fn isValidCSSVariable(value: []const u8) bool {
    if (value.len < 8) return false; // "var(--x)" minimum
    if (!std.mem.startsWith(u8, value, "var(")) return false;
    if (value[value.len - 1] != ')') return false;

    const content = value[4 .. value.len - 1];

    // Find comma for fallback
    if (std.mem.indexOf(u8, content, ",")) |comma_pos| {
        const var_name = std.mem.trim(u8, content[0..comma_pos], " \t");
        const fallback = std.mem.trim(u8, content[comma_pos + 1 ..], " \t");
        return isValidVarName(var_name) and fallback.len > 0;
    }

    // No fallback, just variable name
    const var_name = std.mem.trim(u8, content, " \t");
    return isValidVarName(var_name);
}

/// Validates CSS variable name (--name)
/// Must start with -- and contain only valid characters
fn isValidVarName(name: []const u8) bool {
    if (name.len < 3) return false; // "--x" minimum
    if (!std.mem.startsWith(u8, name, "--")) return false;

    // Check valid characters after --
    // Valid: alphanumeric, dash, underscore
    for (name[2..]) |c| {
        const valid = std.ascii.isAlphanumeric(c) or c == '-' or c == '_';
        if (!valid) return false;
    }

    return true;
}

/// Extract variable name from var() reference
pub fn extractVariableName(value: []const u8) ?[]const u8 {
    if (!isValidCSSVariable(value)) return null;

    const content = value[4 .. value.len - 1];

    // Find comma for fallback
    if (std.mem.indexOf(u8, content, ",")) |comma_pos| {
        return std.mem.trim(u8, content[0..comma_pos], " \t");
    }

    return std.mem.trim(u8, content, " \t");
}

/// Extract fallback value from var() reference (if present)
pub fn extractFallback(value: []const u8) ?[]const u8 {
    if (!isValidCSSVariable(value)) return null;

    const content = value[4 .. value.len - 1];

    // Find comma for fallback
    if (std.mem.indexOf(u8, content, ",")) |comma_pos| {
        const fallback = std.mem.trim(u8, content[comma_pos + 1 ..], " \t");
        if (fallback.len > 0) return fallback;
    }

    return null;
}

// ============================================================================
// Tests
// ============================================================================

test "validate basic CSS variable" {
    try std.testing.expect(isValidCSSVariable("var(--color)"));
    try std.testing.expect(isValidCSSVariable("var(--primary-color)"));
    try std.testing.expect(isValidCSSVariable("var(--bg_color)"));
    try std.testing.expect(isValidCSSVariable("var(--color-blue-500)"));
}

test "validate CSS variable with fallback" {
    try std.testing.expect(isValidCSSVariable("var(--color, blue)"));
    try std.testing.expect(isValidCSSVariable("var(--size, 16px)"));
    try std.testing.expect(isValidCSSVariable("var(--bg, #000000)"));
    try std.testing.expect(isValidCSSVariable("var(--font, 'Arial')"));
}

test "validate CSS variable with spaces" {
    try std.testing.expect(isValidCSSVariable("var( --color )"));
    try std.testing.expect(isValidCSSVariable("var(--color , blue)"));
    try std.testing.expect(isValidCSSVariable("var( --color , blue )"));
}

test "reject invalid CSS variables" {
    // Missing var()
    try std.testing.expect(!isValidCSSVariable("--color"));

    // Missing --
    try std.testing.expect(!isValidCSSVariable("var(color)"));

    // Missing closing paren
    try std.testing.expect(!isValidCSSVariable("var(--color"));

    // Too short
    try std.testing.expect(!isValidCSSVariable("var(--)"));

    // Invalid characters
    try std.testing.expect(!isValidCSSVariable("var(--color!)"));
    try std.testing.expect(!isValidCSSVariable("var(--color@home)"));
    try std.testing.expect(!isValidCSSVariable("var(--color#123)"));

    // Empty fallback
    try std.testing.expect(!isValidCSSVariable("var(--color,)"));
}

test "extract variable name" {
    const name1 = extractVariableName("var(--color)");
    try std.testing.expectEqualStrings("--color", name1.?);

    const name2 = extractVariableName("var(--primary-color)");
    try std.testing.expectEqualStrings("--primary-color", name2.?);

    const name3 = extractVariableName("var(--color, blue)");
    try std.testing.expectEqualStrings("--color", name3.?);

    const name4 = extractVariableName("var( --color )");
    try std.testing.expectEqualStrings("--color", name4.?);
}

test "extract fallback value" {
    const fb1 = extractFallback("var(--color, blue)");
    try std.testing.expectEqualStrings("blue", fb1.?);

    const fb2 = extractFallback("var(--size, 16px)");
    try std.testing.expectEqualStrings("16px", fb2.?);

    const fb3 = extractFallback("var(--color)");
    try std.testing.expect(fb3 == null);

    const fb4 = extractFallback("var( --color , #000 )");
    try std.testing.expectEqualStrings("#000", fb4.?);
}

test "validate variable name" {
    try std.testing.expect(isValidVarName("--color"));
    try std.testing.expect(isValidVarName("--primary-color"));
    try std.testing.expect(isValidVarName("--bg_color"));
    try std.testing.expect(isValidVarName("--color123"));
    try std.testing.expect(isValidVarName("--my-awesome-color-2024"));

    // Invalid
    try std.testing.expect(!isValidVarName("-color"));
    try std.testing.expect(!isValidVarName("--"));
    try std.testing.expect(!isValidVarName("---"));
    try std.testing.expect(!isValidVarName("--color!"));
    try std.testing.expect(!isValidVarName("--color@"));
}
