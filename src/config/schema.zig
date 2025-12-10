const std = @import("std");

/// Headwind configuration schema
/// This uses zig-config for loading and merging configuration
pub const HeadwindConfig = struct {
    /// Project name
    name: []const u8 = "headwind",

    /// Content paths to scan for class names
    content: ContentConfig = .{},

    /// Theme configuration
    theme: ThemeConfig = .{},

    /// Build options
    build: BuildConfig = .{},

    /// Plugin configuration
    plugins: []const PluginConfig = &.{},

    /// Cache configuration
    cache: CacheConfig = .{},

    /// Dark mode configuration
    darkMode: DarkModeConfig = .{},

    /// Prefix for all utility classes
    prefix: []const u8 = "",

    /// Separator for variants (default: ":")
    separator: []const u8 = ":",

    /// Important modifier
    important: bool = false,

    /// Core plugins to disable
    corePlugins: CorePluginsConfig = .{},

    /// Attributify mode configuration (UnoCSS-style)
    attributify: AttributifyConfig = .{},

    /// Grouped syntax mode (UnunuraCSS-style)
    groupedSyntax: GroupedSyntaxConfig = .{},
};

pub const ContentConfig = struct {
    /// Paths to scan (glob patterns)
    files: []const []const u8 = &.{
        "src/**/*.{html,js,jsx,ts,tsx,vue,svelte}",
    },

    /// Paths to exclude
    exclude: []const []const u8 = &.{
        "node_modules/**",
        ".git/**",
        "dist/**",
        "build/**",
    },

    /// Relative to this directory
    relative: ?[]const u8 = null,
};

pub const ThemeConfig = struct {
    /// Color palette
    colors: ?std.json.Value = null,

    /// Spacing scale
    spacing: ?std.json.Value = null,

    /// Font families
    fontFamily: ?std.json.Value = null,

    /// Font sizes
    fontSize: ?std.json.Value = null,

    /// Font weights
    fontWeight: ?std.json.Value = null,

    /// Line heights
    lineHeight: ?std.json.Value = null,

    /// Letter spacing
    letterSpacing: ?std.json.Value = null,

    /// Breakpoints
    screens: ?std.json.Value = null,

    /// Border radius
    borderRadius: ?std.json.Value = null,

    /// Box shadows
    boxShadow: ?std.json.Value = null,

    /// Extend theme (merge with defaults)
    extend: ?std.json.Value = null,
};

pub const BuildConfig = struct {
    /// Output file path
    output: []const u8 = "dist/headwind.css",

    /// Minify output
    minify: bool = false,

    /// Generate source maps
    sourcemap: bool = false,

    /// Watch mode
    watch: bool = false,

    /// Preflight (CSS reset)
    preflight: bool = true,

    /// Output mode
    mode: BuildMode = .development,
};

pub const BuildMode = enum {
    development,
    production,
};

pub const PluginConfig = struct {
    /// Plugin name or path
    name: []const u8,

    /// Plugin options
    options: ?std.json.Value = null,
};

pub const CacheConfig = struct {
    /// Enable caching
    enabled: bool = true,

    /// Cache directory
    dir: []const u8 = ".headwind-cache",

    /// Cache TTL in milliseconds
    ttl: u32 = 3600000, // 1 hour
};

pub const DarkModeConfig = struct {
    /// Strategy: "class" or "media"
    strategy: DarkModeStrategy = .@"class",

    /// Class name for dark mode (when strategy is "class")
    className: []const u8 = "dark",
};

pub const DarkModeStrategy = enum {
    @"class",
    media,
    selector,
};

/// Attributify mode configuration
/// Allows using utility classes as HTML attributes
/// Example: <div flex="~ col" items="center"> instead of class="flex flex-col items-center"
pub const AttributifyConfig = struct {
    /// Enable attributify mode
    enabled: bool = false,

    /// Strict mode - only parse known utility prefixes as attributes
    /// When false, any attribute with valid utility values will be parsed
    strict: bool = true,

    /// Prefix for valueless attributes (e.g., prefix="un-" -> <div un-flex>)
    prefix: []const u8 = "",

    /// List of prefixes to always treat as utilities
    /// e.g., ["flex", "grid", "p", "m", "bg", "text", "border"]
    prefixes: []const []const u8 = &.{
        "flex", "grid", "inline", "block", "hidden",
        "p", "px", "py", "pt", "pr", "pb", "pl", "ps", "pe",
        "m", "mx", "my", "mt", "mr", "mb", "ml", "ms", "me",
        "w", "h", "min", "max", "size",
        "bg", "text", "font", "leading", "tracking",
        "border", "rounded", "ring", "outline",
        "shadow", "opacity", "blur",
        "gap", "space",
        "items", "justify", "content", "self", "place",
        "top", "right", "bottom", "left", "inset",
        "z", "order",
        "overflow", "overscroll",
        "cursor", "select", "pointer",
        "transition", "duration", "ease", "delay",
        "animate", "transform", "scale", "rotate", "translate", "skew",
        "origin",
        "col", "row",
        "aspect", "object",
        "list", "decoration",
        "underline", "line", "no",
        "break", "hyphens", "whitespace", "truncate",
        "sr", "not",
        "fill", "stroke",
        "table", "caption",
        "filter", "backdrop",
        "mix", "isolation",
        "accent", "caret", "scroll",
        "snap", "touch", "resize", "appearance",
        "columns", "break",
        "divide",
    },

    /// Ignore these attributes (never treat as utilities)
    ignoreAttributes: []const []const u8 = &.{
        "class", "className", "id", "style", "href", "src", "alt", "title",
        "type", "name", "value", "placeholder", "data-*", "aria-*",
        "onclick", "onchange", "onsubmit", "onload", "onerror",
    },
};

/// Grouped syntax configuration (UnunuraCSS-style)
/// Allows grouping utilities with brackets and colon syntax
/// Example: flex[col jc-center ai-center] or bg:black
pub const GroupedSyntaxConfig = struct {
    /// Enable grouped syntax parsing
    enabled: bool = false,

    /// Enable bracket grouping: prefix[val1 val2 val3]
    /// e.g., flex[col jc-center ai-center] -> flex-col justify-center items-center
    brackets: bool = true,

    /// Enable colon shorthand: prefix:value
    /// e.g., bg:black -> bg-black
    colonShorthand: bool = true,

    /// Enable reset utilities: reset:type
    /// e.g., reset:meyer, reset:normalize, reset:tailwind
    resets: bool = true,

    /// Expansion rules for grouped values
    /// Maps short forms to full utility names
    /// Key: prefix, Value: map of short->full
    expansions: ?std.json.Value = null,
};

pub const CorePluginsConfig = struct {
    preflight: bool = true,
    container: bool = true,
    accessibility: bool = true,
    pointerEvents: bool = true,
    visibility: bool = true,
    position: bool = true,
    inset: bool = true,
    zIndex: bool = true,
    order: bool = true,
    gridColumn: bool = true,
    gridColumnStart: bool = true,
    gridColumnEnd: bool = true,
    gridRow: bool = true,
    gridRowStart: bool = true,
    gridRowEnd: bool = true,
    float: bool = true,
    clear: bool = true,
    margin: bool = true,
    padding: bool = true,
    space: bool = true,
    width: bool = true,
    minWidth: bool = true,
    maxWidth: bool = true,
    height: bool = true,
    minHeight: bool = true,
    maxHeight: bool = true,
    fontSize: bool = true,
    fontWeight: bool = true,
    textAlign: bool = true,
    textColor: bool = true,
    backgroundColor: bool = true,
    borderColor: bool = true,
    borderRadius: bool = true,
    borderWidth: bool = true,
    display: bool = true,
    flex: bool = true,
    flexDirection: bool = true,
    flexWrap: bool = true,
    alignItems: bool = true,
    justifyContent: bool = true,
    gap: bool = true,
    grid: bool = true,
    gridTemplateColumns: bool = true,
    gridTemplateRows: bool = true,
};

/// Default configuration
pub fn defaultConfig() HeadwindConfig {
    return .{};
}

/// Validate configuration
pub fn validate(config: *const HeadwindConfig) !void {
    if (config.content.files.len == 0) {
        return error.ConfigInvalid;
    }

    if (config.separator.len == 0) {
        return error.ConfigInvalid;
    }

    // Validate build output path
    if (config.build.output.len == 0) {
        return error.ConfigInvalid;
    }
}

test "defaultConfig" {
    const config = defaultConfig();
    try std.testing.expectEqualStrings("headwind", config.name);
    try std.testing.expectEqualStrings(":", config.separator);
}

test "validate" {
    const config = defaultConfig();
    try validate(&config);
}
