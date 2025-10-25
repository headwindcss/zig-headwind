const std = @import("std");
const SourceMapGenerator = @import("generator.zig").SourceMapGenerator;
const types = @import("../core/types.zig");

/// CSS output with source map support
pub const CSSOutput = struct {
    css: []const u8,
    source_map: ?[]const u8,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *CSSOutput) void {
        self.allocator.free(self.css);
        if (self.source_map) |map| {
            self.allocator.free(map);
        }
    }
};

/// Enhanced CSS builder with source map tracking
pub const SourceMappedCSSBuilder = struct {
    allocator: std.mem.Allocator,
    css: std.ArrayList(u8),
    source_map: ?*SourceMapGenerator,
    current_line: u32,
    current_column: u32,
    output_file: []const u8,

    pub fn init(allocator: std.mem.Allocator, output_file: []const u8, enable_source_maps: bool) !SourceMappedCSSBuilder {
        return .{
            .allocator = allocator,
            .css = std.ArrayList(u8).init(allocator),
            .source_map = if (enable_source_maps) blk: {
                var gen = try allocator.create(SourceMapGenerator);
                gen.* = SourceMapGenerator.init(allocator, output_file);
                break :blk gen;
            } else null,
            .current_line = 0,
            .current_column = 0,
            .output_file = output_file,
        };
    }

    pub fn deinit(self: *SourceMappedCSSBuilder) void {
        self.css.deinit();
        if (self.source_map) |map| {
            map.deinit();
            self.allocator.destroy(map);
        }
    }

    /// Append CSS with source location tracking
    pub fn appendWithLocation(
        self: *SourceMappedCSSBuilder,
        css_text: []const u8,
        source_file: ?[]const u8,
        source_line: ?u32,
        source_column: ?u32,
    ) !void {
        // Track source mapping if enabled and location provided
        if (self.source_map) |map| {
            if (source_file != null and source_line != null and source_column != null) {
                try map.addMapping(
                    self.current_line,
                    self.current_column,
                    source_file.?,
                    source_line.?,
                    source_column.?,
                );
            }
        }

        // Append the CSS text
        try self.css.appendSlice(css_text);

        // Update current position
        for (css_text) |char| {
            if (char == '\n') {
                self.current_line += 1;
                self.current_column = 0;
            } else {
                self.current_column += 1;
            }
        }
    }

    /// Append CSS without source tracking
    pub fn append(self: *SourceMappedCSSBuilder, css_text: []const u8) !void {
        try self.appendWithLocation(css_text, null, null, null);
    }

    /// Add a CSS rule with source location
    pub fn addRule(
        self: *SourceMappedCSSBuilder,
        selector: []const u8,
        declarations: std.StringHashMap([]const u8),
        source_location: ?types.SourceLocation,
    ) !void {
        // Add mapping for the rule start
        if (source_location) |loc| {
            try self.appendWithLocation(selector, loc.file, loc.line, loc.column);
        } else {
            try self.append(selector);
        }

        try self.append(" {\n");

        // Add declarations
        var iter = declarations.iterator();
        while (iter.next()) |entry| {
            try self.append("  ");
            try self.append(entry.key_ptr.*);
            try self.append(": ");
            try self.append(entry.value_ptr.*);
            try self.append(";\n");
        }

        try self.append("}\n");
    }

    /// Finalize and generate output
    pub fn finalize(self: *SourceMappedCSSBuilder) !CSSOutput {
        var css = try self.css.toOwnedSlice();
        errdefer self.allocator.free(css);

        // Generate source map if enabled
        const source_map = if (self.source_map) |map| blk: {
            const map_json = try map.generate();

            // Add source map comment to CSS
            const css_with_comment = try SourceMapGenerator.addSourceMapComment(
                self.allocator,
                css,
                try std.fmt.allocPrint(self.allocator, "{s}.map", .{self.output_file}),
            );

            self.allocator.free(css);
            css = css_with_comment;

            break :blk map_json;
        } else null;

        return CSSOutput{
            .css = css,
            .source_map = source_map,
            .allocator = self.allocator,
        };
    }
};

/// Helper to write CSS and source map to files
pub fn writeOutput(output: *const CSSOutput, css_path: []const u8) !void {
    // Write CSS file
    const css_file = try std.fs.cwd().createFile(css_path, .{});
    defer css_file.close();
    try css_file.writeAll(output.css);

    // Write source map if present
    if (output.source_map) |map| {
        const map_path = try std.fmt.allocPrint(
            output.allocator,
            "{s}.map",
            .{css_path},
        );
        defer output.allocator.free(map_path);

        const map_file = try std.fs.cwd().createFile(map_path, .{});
        defer map_file.close();
        try map_file.writeAll(map);
    }
}

// ============================================================================
// Tests
// ============================================================================

test "source mapped CSS builder basic" {
    const allocator = std.testing.allocator;

    var builder = try SourceMappedCSSBuilder.init(allocator, "output.css", true);
    defer builder.deinit();

    // Add a rule with source location
    try builder.appendWithLocation(".flex", "src/index.html", 10, 5);
    try builder.append(" { display: flex; }\n");

    const output = try builder.finalize();
    defer {
        allocator.free(output.css);
        if (output.source_map) |map| allocator.free(map);
    }

    try std.testing.expect(std.mem.indexOf(u8, output.css, ".flex { display: flex; }") != null);
    try std.testing.expect(output.source_map != null);

    if (output.source_map) |map| {
        try std.testing.expect(std.mem.indexOf(u8, map, "src/index.html") != null);
        try std.testing.expect(std.mem.indexOf(u8, map, "\"version\": 3") != null);
    }
}

test "CSS builder without source maps" {
    const allocator = std.testing.allocator;

    var builder = try SourceMappedCSSBuilder.init(allocator, "output.css", false);
    defer builder.deinit();

    try builder.append(".flex { display: flex; }\n");

    const output = try builder.finalize();
    defer {
        allocator.free(output.css);
        if (output.source_map) |map| allocator.free(map);
    }

    try std.testing.expect(output.source_map == null);
}
