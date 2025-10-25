const std = @import("std");

/// Theme configuration structure
/// Supports Tailwind-style theme values with nested paths
pub const ThemeConfig = struct {
    allocator: std.mem.Allocator,
    colors: std.StringHashMap(ThemeValue),
    spacing: std.StringHashMap(ThemeValue),
    fontSize: std.StringHashMap(ThemeValue),
    fontFamily: std.StringHashMap(ThemeValue),
    fontWeight: std.StringHashMap(ThemeValue),
    lineHeight: std.StringHashMap(ThemeValue),
    letterSpacing: std.StringHashMap(ThemeValue),
    borderRadius: std.StringHashMap(ThemeValue),
    borderWidth: std.StringHashMap(ThemeValue),
    boxShadow: std.StringHashMap(ThemeValue),
    screens: std.StringHashMap(ThemeValue),
    zIndex: std.StringHashMap(ThemeValue),
    opacity: std.StringHashMap(ThemeValue),

    pub fn init(allocator: std.mem.Allocator) ThemeConfig {
        return .{
            .allocator = allocator,
            .colors = std.StringHashMap(ThemeValue).init(allocator),
            .spacing = std.StringHashMap(ThemeValue).init(allocator),
            .fontSize = std.StringHashMap(ThemeValue).init(allocator),
            .fontFamily = std.StringHashMap(ThemeValue).init(allocator),
            .fontWeight = std.StringHashMap(ThemeValue).init(allocator),
            .lineHeight = std.StringHashMap(ThemeValue).init(allocator),
            .letterSpacing = std.StringHashMap(ThemeValue).init(allocator),
            .borderRadius = std.StringHashMap(ThemeValue).init(allocator),
            .borderWidth = std.StringHashMap(ThemeValue).init(allocator),
            .boxShadow = std.StringHashMap(ThemeValue).init(allocator),
            .screens = std.StringHashMap(ThemeValue).init(allocator),
            .zIndex = std.StringHashMap(ThemeValue).init(allocator),
            .opacity = std.StringHashMap(ThemeValue).init(allocator),
        };
    }

    pub fn deinit(self: *ThemeConfig) void {
        self.deinitMap(&self.colors);
        self.deinitMap(&self.spacing);
        self.deinitMap(&self.fontSize);
        self.deinitMap(&self.fontFamily);
        self.deinitMap(&self.fontWeight);
        self.deinitMap(&self.lineHeight);
        self.deinitMap(&self.letterSpacing);
        self.deinitMap(&self.borderRadius);
        self.deinitMap(&self.borderWidth);
        self.deinitMap(&self.boxShadow);
        self.deinitMap(&self.screens);
        self.deinitMap(&self.zIndex);
        self.deinitMap(&self.opacity);
    }

    fn deinitMap(self: *ThemeConfig, map: *std.StringHashMap(ThemeValue)) void {
        var iter = map.iterator();
        while (iter.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            entry.value_ptr.deinit(self.allocator);
        }
        map.deinit();
    }

    /// Resolve a theme path to its value
    /// Example: "colors.blue.500" -> "#3b82f6"
    pub fn resolve(self: *const ThemeConfig, path: []const u8) ?[]const u8 {
        var parts = std.mem.splitScalar(u8, path, '.');
        const category = parts.next() orelse return null;

        // Get the appropriate category map
        const map = self.getCategoryMap(category) orelse return null;

        // Build the key from remaining parts
        const rest = path[category.len..];
        if (rest.len == 0) return null;

        const key = if (rest[0] == '.') rest[1..] else rest;
        if (key.len == 0) return null;

        // Look up the value
        if (map.get(key)) |value| {
            return value.asString();
        }

        return null;
    }

    fn getCategoryMap(self: *const ThemeConfig, category: []const u8) ?*const std.StringHashMap(ThemeValue) {
        if (std.mem.eql(u8, category, "colors")) return &self.colors;
        if (std.mem.eql(u8, category, "spacing")) return &self.spacing;
        if (std.mem.eql(u8, category, "fontSize")) return &self.fontSize;
        if (std.mem.eql(u8, category, "fontFamily")) return &self.fontFamily;
        if (std.mem.eql(u8, category, "fontWeight")) return &self.fontWeight;
        if (std.mem.eql(u8, category, "lineHeight")) return &self.lineHeight;
        if (std.mem.eql(u8, category, "letterSpacing")) return &self.letterSpacing;
        if (std.mem.eql(u8, category, "borderRadius")) return &self.borderRadius;
        if (std.mem.eql(u8, category, "borderWidth")) return &self.borderWidth;
        if (std.mem.eql(u8, category, "boxShadow")) return &self.boxShadow;
        if (std.mem.eql(u8, category, "screens")) return &self.screens;
        if (std.mem.eql(u8, category, "zIndex")) return &self.zIndex;
        if (std.mem.eql(u8, category, "opacity")) return &self.opacity;
        return null;
    }

    /// Create default Tailwind theme
    pub fn createDefault(allocator: std.mem.Allocator) !ThemeConfig {
        var theme = ThemeConfig.init(allocator);

        // Default colors
        try theme.colors.put(try allocator.dupe(u8, "blue.500"), ThemeValue{ .string = try allocator.dupe(u8, "#3b82f6") });
        try theme.colors.put(try allocator.dupe(u8, "blue.600"), ThemeValue{ .string = try allocator.dupe(u8, "#2563eb") });
        try theme.colors.put(try allocator.dupe(u8, "red.500"), ThemeValue{ .string = try allocator.dupe(u8, "#ef4444") });
        try theme.colors.put(try allocator.dupe(u8, "green.500"), ThemeValue{ .string = try allocator.dupe(u8, "#22c55e") });
        try theme.colors.put(try allocator.dupe(u8, "gray.500"), ThemeValue{ .string = try allocator.dupe(u8, "#6b7280") });
        try theme.colors.put(try allocator.dupe(u8, "slate.500"), ThemeValue{ .string = try allocator.dupe(u8, "#64748b") });

        // Default spacing
        try theme.spacing.put(try allocator.dupe(u8, "0"), ThemeValue{ .string = try allocator.dupe(u8, "0px") });
        try theme.spacing.put(try allocator.dupe(u8, "1"), ThemeValue{ .string = try allocator.dupe(u8, "0.25rem") });
        try theme.spacing.put(try allocator.dupe(u8, "2"), ThemeValue{ .string = try allocator.dupe(u8, "0.5rem") });
        try theme.spacing.put(try allocator.dupe(u8, "4"), ThemeValue{ .string = try allocator.dupe(u8, "1rem") });
        try theme.spacing.put(try allocator.dupe(u8, "8"), ThemeValue{ .string = try allocator.dupe(u8, "2rem") });
        try theme.spacing.put(try allocator.dupe(u8, "16"), ThemeValue{ .string = try allocator.dupe(u8, "4rem") });

        // Default font sizes
        try theme.fontSize.put(try allocator.dupe(u8, "sm"), ThemeValue{ .string = try allocator.dupe(u8, "0.875rem") });
        try theme.fontSize.put(try allocator.dupe(u8, "base"), ThemeValue{ .string = try allocator.dupe(u8, "1rem") });
        try theme.fontSize.put(try allocator.dupe(u8, "lg"), ThemeValue{ .string = try allocator.dupe(u8, "1.125rem") });
        try theme.fontSize.put(try allocator.dupe(u8, "xl"), ThemeValue{ .string = try allocator.dupe(u8, "1.25rem") });
        try theme.fontSize.put(try allocator.dupe(u8, "2xl"), ThemeValue{ .string = try allocator.dupe(u8, "1.5rem") });

        // Default border radius
        try theme.borderRadius.put(try allocator.dupe(u8, "none"), ThemeValue{ .string = try allocator.dupe(u8, "0px") });
        try theme.borderRadius.put(try allocator.dupe(u8, "sm"), ThemeValue{ .string = try allocator.dupe(u8, "0.125rem") });
        try theme.borderRadius.put(try allocator.dupe(u8, "md"), ThemeValue{ .string = try allocator.dupe(u8, "0.375rem") });
        try theme.borderRadius.put(try allocator.dupe(u8, "lg"), ThemeValue{ .string = try allocator.dupe(u8, "0.5rem") });
        try theme.borderRadius.put(try allocator.dupe(u8, "full"), ThemeValue{ .string = try allocator.dupe(u8, "9999px") });

        return theme;
    }
};

/// Theme value (can be string or nested object)
pub const ThemeValue = union(enum) {
    string: []const u8,
    object: std.StringHashMap(ThemeValue),

    pub fn deinit(self: *ThemeValue, allocator: std.mem.Allocator) void {
        switch (self.*) {
            .string => |s| allocator.free(s),
            .object => |*obj| {
                var iter = obj.iterator();
                while (iter.next()) |entry| {
                    allocator.free(entry.key_ptr.*);
                    entry.value_ptr.deinit(allocator);
                }
                obj.deinit();
            },
        }
    }

    pub fn asString(self: *const ThemeValue) ?[]const u8 {
        return switch (self.*) {
            .string => |s| s,
            .object => null,
        };
    }
};

// ============================================================================
// Tests
// ============================================================================

test "theme config init and deinit" {
    const allocator = std.testing.allocator;
    var theme = ThemeConfig.init(allocator);
    defer theme.deinit();
}

test "theme config add and resolve values" {
    const allocator = std.testing.allocator;
    var theme = ThemeConfig.init(allocator);
    defer theme.deinit();

    try theme.colors.put(
        try allocator.dupe(u8, "blue.500"),
        ThemeValue{ .string = try allocator.dupe(u8, "#3b82f6") },
    );

    const resolved = theme.resolve("colors.blue.500");
    try std.testing.expectEqualStrings("#3b82f6", resolved.?);
}

test "theme config resolve missing value" {
    const allocator = std.testing.allocator;
    var theme = ThemeConfig.init(allocator);
    defer theme.deinit();

    const resolved = theme.resolve("colors.blue.500");
    try std.testing.expect(resolved == null);
}

test "theme config default theme" {
    const allocator = std.testing.allocator;
    var theme = try ThemeConfig.createDefault(allocator);
    defer theme.deinit();

    // Test colors
    const blue = theme.resolve("colors.blue.500");
    try std.testing.expectEqualStrings("#3b82f6", blue.?);

    // Test spacing
    const spacing = theme.resolve("spacing.4");
    try std.testing.expectEqualStrings("1rem", spacing.?);

    // Test fontSize
    const fontSize = theme.resolve("fontSize.lg");
    try std.testing.expectEqualStrings("1.125rem", fontSize.?);

    // Test borderRadius
    const radius = theme.resolve("borderRadius.full");
    try std.testing.expectEqualStrings("9999px", radius.?);
}

test "theme config invalid category" {
    const allocator = std.testing.allocator;
    var theme = try ThemeConfig.createDefault(allocator);
    defer theme.deinit();

    const resolved = theme.resolve("invalid.foo.bar");
    try std.testing.expect(resolved == null);
}

test "theme config malformed path" {
    const allocator = std.testing.allocator;
    var theme = try ThemeConfig.createDefault(allocator);
    defer theme.deinit();

    try std.testing.expect(theme.resolve("colors") == null);
    try std.testing.expect(theme.resolve("") == null);
    try std.testing.expect(theme.resolve(".") == null);
}
