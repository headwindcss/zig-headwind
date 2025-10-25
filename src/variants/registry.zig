const std = @import("std");

/// Variant type categories
pub const VariantType = enum {
    pseudo_class,
    pseudo_element,
    state,
    media_query,
    print,
    supports_query,
    aria_attribute,
    data_attribute,
    directional,
    modifier,
    arbitrary,
    responsive,
};

/// Variant definition
pub const VariantDefinition = struct {
    name: []const u8,
    type: VariantType,
    css_selector: []const u8,
    description: []const u8,
    order: u32, // For stacking order resolution
};

/// Comprehensive variant registry
pub const VariantRegistry = struct {
    allocator: std.mem.Allocator,
    variants: std.StringHashMap(VariantDefinition),

    pub fn init(allocator: std.mem.Allocator) VariantRegistry {
        return .{
            .allocator = allocator,
            .variants = std.StringHashMap(VariantDefinition).init(allocator),
        };
    }

    pub fn deinit(self: *VariantRegistry) void {
        self.variants.deinit();
    }

    /// Create registry with all default variants
    pub fn createDefault(allocator: std.mem.Allocator) !VariantRegistry {
        var registry = VariantRegistry.init(allocator);

        // Pseudo-class variants (order: 100-200)
        try registry.addPseudoClassVariants();

        // Pseudo-element variants (order: 200-300)
        try registry.addPseudoElementVariants();

        // State variants (order: 300-400)
        try registry.addStateVariants();

        // Media query variants (order: 400-500)
        try registry.addMediaQueryVariants();

        // Print variant (order: 500)
        try registry.addPrintVariant();

        // Supports query variants (order: 600-700)
        try registry.addSupportsVariants();

        // ARIA attribute variants (order: 700-800)
        try registry.addAriaVariants();

        // Data attribute variants (order: 800-900)
        try registry.addDataVariants();

        // Directional variants (order: 900-1000)
        try registry.addDirectionalVariants();

        // Responsive variants (order: 1000+)
        try registry.addResponsiveVariants();

        return registry;
    }

    fn addPseudoClassVariants(self: *VariantRegistry) !void {
        const variants = [_]struct { name: []const u8, selector: []const u8, desc: []const u8, order: u32 }{
            .{ .name = "hover", .selector = ":hover", .desc = "On mouse hover", .order = 100 },
            .{ .name = "focus", .selector = ":focus", .desc = "On focus", .order = 101 },
            .{ .name = "focus-visible", .selector = ":focus-visible", .desc = "On keyboard focus", .order = 102 },
            .{ .name = "focus-within", .selector = ":focus-within", .desc = "When child has focus", .order = 103 },
            .{ .name = "active", .selector = ":active", .desc = "On click/activation", .order = 104 },
            .{ .name = "visited", .selector = ":visited", .desc = "Visited links", .order = 105 },
            .{ .name = "target", .selector = ":target", .desc = "URL fragment target", .order = 106 },
            .{ .name = "first", .selector = ":first-child", .desc = "First child", .order = 110 },
            .{ .name = "last", .selector = ":last-child", .desc = "Last child", .order = 111 },
            .{ .name = "only", .selector = ":only-child", .desc = "Only child", .order = 112 },
            .{ .name = "odd", .selector = ":nth-child(odd)", .desc = "Odd children", .order = 113 },
            .{ .name = "even", .selector = ":nth-child(even)", .desc = "Even children", .order = 114 },
            .{ .name = "first-of-type", .selector = ":first-of-type", .desc = "First of type", .order = 115 },
            .{ .name = "last-of-type", .selector = ":last-of-type", .desc = "Last of type", .order = 116 },
            .{ .name = "only-of-type", .selector = ":only-of-type", .desc = "Only of type", .order = 117 },
            .{ .name = "empty", .selector = ":empty", .desc = "Empty elements", .order = 120 },
            .{ .name = "disabled", .selector = ":disabled", .desc = "Disabled state", .order = 121 },
            .{ .name = "enabled", .selector = ":enabled", .desc = "Enabled state", .order = 122 },
            .{ .name = "checked", .selector = ":checked", .desc = "Checked state", .order = 123 },
            .{ .name = "indeterminate", .selector = ":indeterminate", .desc = "Indeterminate state", .order = 124 },
            .{ .name = "default", .selector = ":default", .desc = "Default in group", .order = 125 },
            .{ .name = "required", .selector = ":required", .desc = "Required input", .order = 126 },
            .{ .name = "valid", .selector = ":valid", .desc = "Valid input", .order = 127 },
            .{ .name = "invalid", .selector = ":invalid", .desc = "Invalid input", .order = 128 },
            .{ .name = "in-range", .selector = ":in-range", .desc = "Value in range", .order = 129 },
            .{ .name = "out-of-range", .selector = ":out-of-range", .desc = "Value out of range", .order = 130 },
            .{ .name = "placeholder-shown", .selector = ":placeholder-shown", .desc = "Placeholder visible", .order = 131 },
            .{ .name = "autofill", .selector = ":autofill", .desc = "Autofilled input", .order = 132 },
            .{ .name = "read-only", .selector = ":read-only", .desc = "Read-only input", .order = 133 },
        };

        for (variants) |v| {
            try self.variants.put(v.name, .{
                .name = v.name,
                .type = .pseudo_class,
                .css_selector = v.selector,
                .description = v.desc,
                .order = v.order,
            });
        }
    }

    fn addPseudoElementVariants(self: *VariantRegistry) !void {
        const variants = [_]struct { name: []const u8, selector: []const u8, desc: []const u8, order: u32 }{
            .{ .name = "before", .selector = "::before", .desc = "Before element", .order = 200 },
            .{ .name = "after", .selector = "::after", .desc = "After element", .order = 201 },
            .{ .name = "first-letter", .selector = "::first-letter", .desc = "First letter", .order = 202 },
            .{ .name = "first-line", .selector = "::first-line", .desc = "First line", .order = 203 },
            .{ .name = "marker", .selector = "::marker", .desc = "List marker", .order = 204 },
            .{ .name = "selection", .selector = "::selection", .desc = "Selected text", .order = 205 },
            .{ .name = "file", .selector = "::file-selector-button", .desc = "File input button", .order = 206 },
            .{ .name = "backdrop", .selector = "::backdrop", .desc = "Dialog backdrop", .order = 207 },
            .{ .name = "placeholder", .selector = "::placeholder", .desc = "Input placeholder", .order = 208 },
        };

        for (variants) |v| {
            try self.variants.put(v.name, .{
                .name = v.name,
                .type = .pseudo_element,
                .css_selector = v.selector,
                .description = v.desc,
                .order = v.order,
            });
        }
    }

    fn addStateVariants(self: *VariantRegistry) !void {
        const variants = [_]struct { name: []const u8, selector: []const u8, desc: []const u8, order: u32 }{
            .{ .name = "open", .selector = "[open]", .desc = "Open state", .order = 300 },
            .{ .name = "closed", .selector = ":not([open])", .desc = "Closed state", .order = 301 },
        };

        for (variants) |v| {
            try self.variants.put(v.name, .{
                .name = v.name,
                .type = .state,
                .css_selector = v.selector,
                .description = v.desc,
                .order = v.order,
            });
        }
    }

    fn addMediaQueryVariants(self: *VariantRegistry) !void {
        const variants = [_]struct { name: []const u8, selector: []const u8, desc: []const u8, order: u32 }{
            .{ .name = "prefers-reduced-motion", .selector = "@media (prefers-reduced-motion: reduce)", .desc = "Reduced motion preference", .order = 400 },
            .{ .name = "prefers-color-scheme-dark", .selector = "@media (prefers-color-scheme: dark)", .desc = "Dark color scheme", .order = 401 },
            .{ .name = "prefers-color-scheme-light", .selector = "@media (prefers-color-scheme: light)", .desc = "Light color scheme", .order = 402 },
            .{ .name = "prefers-contrast-more", .selector = "@media (prefers-contrast: more)", .desc = "More contrast", .order = 403 },
            .{ .name = "prefers-contrast-less", .selector = "@media (prefers-contrast: less)", .desc = "Less contrast", .order = 404 },
            .{ .name = "dark", .selector = "@media (prefers-color-scheme: dark)", .desc = "Dark mode", .order = 405 },
            .{ .name = "light", .selector = "@media (prefers-color-scheme: light)", .desc = "Light mode", .order = 406 },
            .{ .name = "motion-safe", .selector = "@media (prefers-reduced-motion: no-preference)", .desc = "Motion enabled", .order = 407 },
            .{ .name = "motion-reduce", .selector = "@media (prefers-reduced-motion: reduce)", .desc = "Motion reduced", .order = 408 },
        };

        for (variants) |v| {
            try self.variants.put(v.name, .{
                .name = v.name,
                .type = .media_query,
                .css_selector = v.selector,
                .description = v.desc,
                .order = v.order,
            });
        }
    }

    fn addPrintVariant(self: *VariantRegistry) !void {
        try self.variants.put("print", .{
            .name = "print",
            .type = .print,
            .css_selector = "@media print",
            .description = "Print media",
            .order = 500,
        });
    }

    fn addSupportsVariants(self: *VariantRegistry) !void {
        const variants = [_]struct { name: []const u8, selector: []const u8, desc: []const u8, order: u32 }{
            .{ .name = "supports-grid", .selector = "@supports (display: grid)", .desc = "Grid support", .order = 600 },
            .{ .name = "supports-backdrop-blur", .selector = "@supports (backdrop-filter: blur(0))", .desc = "Backdrop blur support", .order = 601 },
        };

        for (variants) |v| {
            try self.variants.put(v.name, .{
                .name = v.name,
                .type = .supports_query,
                .css_selector = v.selector,
                .description = v.desc,
                .order = v.order,
            });
        }
    }

    fn addAriaVariants(self: *VariantRegistry) !void {
        const variants = [_]struct { name: []const u8, selector: []const u8, desc: []const u8, order: u32 }{
            .{ .name = "aria-checked", .selector = "[aria-checked=\"true\"]", .desc = "ARIA checked", .order = 700 },
            .{ .name = "aria-disabled", .selector = "[aria-disabled=\"true\"]", .desc = "ARIA disabled", .order = 701 },
            .{ .name = "aria-expanded", .selector = "[aria-expanded=\"true\"]", .desc = "ARIA expanded", .order = 702 },
            .{ .name = "aria-hidden", .selector = "[aria-hidden=\"true\"]", .desc = "ARIA hidden", .order = 703 },
            .{ .name = "aria-pressed", .selector = "[aria-pressed=\"true\"]", .desc = "ARIA pressed", .order = 704 },
            .{ .name = "aria-readonly", .selector = "[aria-readonly=\"true\"]", .desc = "ARIA readonly", .order = 705 },
            .{ .name = "aria-required", .selector = "[aria-required=\"true\"]", .desc = "ARIA required", .order = 706 },
            .{ .name = "aria-selected", .selector = "[aria-selected=\"true\"]", .desc = "ARIA selected", .order = 707 },
        };

        for (variants) |v| {
            try self.variants.put(v.name, .{
                .name = v.name,
                .type = .aria_attribute,
                .css_selector = v.selector,
                .description = v.desc,
                .order = v.order,
            });
        }
    }

    fn addDataVariants(self: *VariantRegistry) !void {
        // Note: data-* variants are typically arbitrary ([data-state="active"])
        // Here we provide some common ones
        const variants = [_]struct { name: []const u8, selector: []const u8, desc: []const u8, order: u32 }{
            .{ .name = "data-active", .selector = "[data-active]", .desc = "Data active", .order = 800 },
            .{ .name = "data-disabled", .selector = "[data-disabled]", .desc = "Data disabled", .order = 801 },
            .{ .name = "data-selected", .selector = "[data-selected]", .desc = "Data selected", .order = 802 },
        };

        for (variants) |v| {
            try self.variants.put(v.name, .{
                .name = v.name,
                .type = .data_attribute,
                .css_selector = v.selector,
                .description = v.desc,
                .order = v.order,
            });
        }
    }

    fn addDirectionalVariants(self: *VariantRegistry) !void {
        const variants = [_]struct { name: []const u8, selector: []const u8, desc: []const u8, order: u32 }{
            .{ .name = "rtl", .selector = "[dir=\"rtl\"]", .desc = "Right-to-left", .order = 900 },
            .{ .name = "ltr", .selector = "[dir=\"ltr\"]", .desc = "Left-to-right", .order = 901 },
        };

        for (variants) |v| {
            try self.variants.put(v.name, .{
                .name = v.name,
                .type = .directional,
                .css_selector = v.selector,
                .description = v.desc,
                .order = v.order,
            });
        }
    }

    fn addResponsiveVariants(self: *VariantRegistry) !void {
        const variants = [_]struct { name: []const u8, selector: []const u8, desc: []const u8, order: u32 }{
            .{ .name = "sm", .selector = "@media (min-width: 640px)", .desc = "Small screens (640px+)", .order = 1000 },
            .{ .name = "md", .selector = "@media (min-width: 768px)", .desc = "Medium screens (768px+)", .order = 1001 },
            .{ .name = "lg", .selector = "@media (min-width: 1024px)", .desc = "Large screens (1024px+)", .order = 1002 },
            .{ .name = "xl", .selector = "@media (min-width: 1280px)", .desc = "Extra large screens (1280px+)", .order = 1003 },
            .{ .name = "2xl", .selector = "@media (min-width: 1536px)", .desc = "2X large screens (1536px+)", .order = 1004 },
        };

        for (variants) |v| {
            try self.variants.put(v.name, .{
                .name = v.name,
                .type = .responsive,
                .css_selector = v.selector,
                .description = v.desc,
                .order = v.order,
            });
        }
    }

    /// Get variant definition
    pub fn get(self: *const VariantRegistry, name: []const u8) ?VariantDefinition {
        return self.variants.get(name);
    }

    /// Check if variant exists
    pub fn has(self: *const VariantRegistry, name: []const u8) bool {
        return self.variants.contains(name);
    }

    /// Get total variant count
    pub fn count(self: *const VariantRegistry) usize {
        return self.variants.count();
    }
};

// ============================================================================
// Tests
// ============================================================================

test "variant registry init and deinit" {
    const allocator = std.testing.allocator;
    var registry = VariantRegistry.init(allocator);
    defer registry.deinit();
}

test "variant registry default variants" {
    const allocator = std.testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    // Should have many variants
    try std.testing.expect(registry.count() > 50);

    // Test pseudo-class variants
    try std.testing.expect(registry.has("hover"));
    try std.testing.expect(registry.has("focus"));
    try std.testing.expect(registry.has("active"));

    // Test pseudo-element variants
    try std.testing.expect(registry.has("before"));
    try std.testing.expect(registry.has("after"));

    // Test state variants
    try std.testing.expect(registry.has("open"));
    try std.testing.expect(registry.has("closed"));

    // Test media query variants
    try std.testing.expect(registry.has("dark"));
    try std.testing.expect(registry.has("prefers-reduced-motion"));

    // Test responsive variants
    try std.testing.expect(registry.has("sm"));
    try std.testing.expect(registry.has("md"));
    try std.testing.expect(registry.has("lg"));
}

test "variant registry get definition" {
    const allocator = std.testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const hover = registry.get("hover");
    try std.testing.expect(hover != null);
    try std.testing.expectEqualStrings(":hover", hover.?.css_selector);
    try std.testing.expect(hover.?.type == .pseudo_class);
}

test "variant registry stacking order" {
    const allocator = std.testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    const hover = registry.get("hover").?;
    const before = registry.get("before").?;
    const dark = registry.get("dark").?;
    const sm = registry.get("sm").?;

    // Verify ordering: pseudo-class < pseudo-element < media < responsive
    try std.testing.expect(hover.order < before.order);
    try std.testing.expect(before.order < dark.order);
    try std.testing.expect(dark.order < sm.order);
}

test "variant registry missing variant" {
    const allocator = std.testing.allocator;
    var registry = try VariantRegistry.createDefault(allocator);
    defer registry.deinit();

    try std.testing.expect(!registry.has("nonexistent"));
    try std.testing.expect(registry.get("nonexistent") == null);
}
