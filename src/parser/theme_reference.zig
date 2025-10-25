const std = @import("std");
const ThemeConfig = @import("../config/theme.zig").ThemeConfig;

/// Parsed theme reference
pub const ThemeReference = struct {
    /// Full path (e.g., "colors.blue.500")
    path: []const u8,
    /// Category (e.g., "colors")
    category: []const u8,
    /// Key within category (e.g., "blue.500")
    key: []const u8,

    pub fn deinit(self: *ThemeReference, allocator: std.mem.Allocator) void {
        allocator.free(self.path);
        allocator.free(self.category);
        allocator.free(self.key);
    }
};

/// Check if value is a theme reference
pub fn isThemeReference(value: []const u8) bool {
    if (value.len < 9) return false; // "theme(x)" minimum
    if (!std.mem.startsWith(u8, value, "theme(")) return false;
    if (value[value.len - 1] != ')') return false;

    const path = value[6 .. value.len - 1];
    return isValidThemePath(path);
}

/// Validate theme path format
fn isValidThemePath(path: []const u8) bool {
    if (path.len == 0) return false;

    // Must have at least one dot (category.key)
    if (std.mem.indexOf(u8, path, ".") == null) return false;

    // Check for valid characters (alphanumeric, dot, dash, underscore)
    for (path) |c| {
        const valid = std.ascii.isAlphanumeric(c) or c == '.' or c == '-' or c == '_';
        if (!valid) return false;
    }

    // Can't start or end with dot
    if (path[0] == '.' or path[path.len - 1] == '.') return false;

    // Can't have consecutive dots
    var prev_was_dot = false;
    for (path) |c| {
        if (c == '.') {
            if (prev_was_dot) return false;
            prev_was_dot = true;
        } else {
            prev_was_dot = false;
        }
    }

    return true;
}

/// Parse theme reference into components
pub fn parseThemeReference(allocator: std.mem.Allocator, value: []const u8) !ThemeReference {
    if (!isThemeReference(value)) {
        return error.NotThemeReference;
    }

    const path = value[6 .. value.len - 1];

    // Split into category and key
    const dot_pos = std.mem.indexOf(u8, path, ".") orelse return error.InvalidThemePath;

    const category = path[0..dot_pos];
    const key = path[dot_pos + 1 ..];

    return ThemeReference{
        .path = try allocator.dupe(u8, path),
        .category = try allocator.dupe(u8, category),
        .key = try allocator.dupe(u8, key),
    };
}

/// Resolve theme reference to actual value
pub fn resolveThemeReference(
    theme: *const ThemeConfig,
    value: []const u8,
    allocator: std.mem.Allocator,
) !?[]const u8 {
    if (!isThemeReference(value)) return null;

    const path = value[6 .. value.len - 1];
    if (theme.resolve(path)) |resolved| {
        return try allocator.dupe(u8, resolved);
    }

    return null;
}

// ============================================================================
// Tests
// ============================================================================

test "validate theme reference syntax" {
    try std.testing.expect(isThemeReference("theme(colors.blue.500)"));
    try std.testing.expect(isThemeReference("theme(spacing.4)"));
    try std.testing.expect(isThemeReference("theme(fontSize.lg)"));
    try std.testing.expect(isThemeReference("theme(borderRadius.md)"));
}

test "reject invalid theme references" {
    // Missing theme()
    try std.testing.expect(!isThemeReference("colors.blue.500"));

    // Missing closing paren
    try std.testing.expect(!isThemeReference("theme(colors.blue.500"));

    // Missing opening paren
    try std.testing.expect(!isThemeReference("themecolors.blue.500)"));

    // No dots (need category.key)
    try std.testing.expect(!isThemeReference("theme(color)"));

    // Invalid characters
    try std.testing.expect(!isThemeReference("theme(colors.blue@500)"));
    try std.testing.expect(!isThemeReference("theme(colors.blue!500)"));

    // Starting/ending with dot
    try std.testing.expect(!isThemeReference("theme(.colors.blue)"));
    try std.testing.expect(!isThemeReference("theme(colors.blue.)"));

    // Consecutive dots
    try std.testing.expect(!isThemeReference("theme(colors..blue)"));

    // Empty
    try std.testing.expect(!isThemeReference("theme()"));

    // Too short
    try std.testing.expect(!isThemeReference("theme(x)"));
}

test "parse theme reference" {
    const allocator = std.testing.allocator;

    var ref = try parseThemeReference(allocator, "theme(colors.blue.500)");
    defer ref.deinit(allocator);

    try std.testing.expectEqualStrings("colors.blue.500", ref.path);
    try std.testing.expectEqualStrings("colors", ref.category);
    try std.testing.expectEqualStrings("blue.500", ref.key);
}

test "parse theme reference with single level key" {
    const allocator = std.testing.allocator;

    var ref = try parseThemeReference(allocator, "theme(spacing.4)");
    defer ref.deinit(allocator);

    try std.testing.expectEqualStrings("spacing.4", ref.path);
    try std.testing.expectEqualStrings("spacing", ref.category);
    try std.testing.expectEqualStrings("4", ref.key);
}

test "parse invalid theme reference fails" {
    const allocator = std.testing.allocator;

    const result = parseThemeReference(allocator, "colors.blue.500");
    try std.testing.expectError(error.NotThemeReference, result);
}

test "resolve theme reference" {
    const allocator = std.testing.allocator;
    var theme = try @import("../config/theme.zig").ThemeConfig.createDefault(allocator);
    defer theme.deinit();

    const resolved = try resolveThemeReference(&theme, "theme(colors.blue.500)", allocator);
    defer if (resolved) |r| allocator.free(r);

    try std.testing.expectEqualStrings("#3b82f6", resolved.?);
}

test "resolve missing theme value" {
    const allocator = std.testing.allocator;
    var theme = try @import("../config/theme.zig").ThemeConfig.createDefault(allocator);
    defer theme.deinit();

    const resolved = try resolveThemeReference(&theme, "theme(colors.purple.500)", allocator);
    try std.testing.expect(resolved == null);
}

test "resolve non-theme reference" {
    const allocator = std.testing.allocator;
    var theme = try @import("../config/theme.zig").ThemeConfig.createDefault(allocator);
    defer theme.deinit();

    const resolved = try resolveThemeReference(&theme, "100px", allocator);
    try std.testing.expect(resolved == null);
}

test "validate theme path" {
    try std.testing.expect(isValidThemePath("colors.blue.500"));
    try std.testing.expect(isValidThemePath("spacing.4"));
    try std.testing.expect(isValidThemePath("fontSize.lg"));
    try std.testing.expect(isValidThemePath("a.b"));

    // Invalid
    try std.testing.expect(!isValidThemePath("colors")); // No dot
    try std.testing.expect(!isValidThemePath(".colors.blue")); // Starts with dot
    try std.testing.expect(!isValidThemePath("colors.blue.")); // Ends with dot
    try std.testing.expect(!isValidThemePath("colors..blue")); // Consecutive dots
    try std.testing.expect(!isValidThemePath("")); // Empty
    try std.testing.expect(!isValidThemePath("colors.blue@500")); // Invalid char
}
