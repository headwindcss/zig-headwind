# Shortcuts and Compile Class Transformer Specification

## Overview

This document specifies the implementation of two major features inspired by UnoCSS:
1. **Shortcuts** - Combine multiple utilities into reusable shorthand classes
2. **Compile Class Transformer** - Compile groups of classes into single optimized classes

## Feature 1: Shortcuts

### Static Shortcuts (Plain Mappings)

Allow users to define reusable class combinations in configuration.

#### Configuration Format

```json
{
  "shortcuts": {
    "btn": "py-2 px-4 font-semibold rounded-lg shadow-md",
    "btn-green": "text-white bg-green-500 hover:bg-green-700",
    "red": "text-red-100",
    "card": "bg-white rounded-lg shadow-md p-6",
    "flex-center": "flex items-center justify-center"
  }
}
```

#### Usage

**HTML:**
```html
<button class="btn btn-green">Click me</button>
<div class="card">Content</div>
```

**Generated CSS:**
```css
/* Expands btn */
.btn {
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
  padding-left: 1rem;
  padding-right: 1rem;
  font-weight: 600;
  border-radius: 0.5rem;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

/* Expands btn-green */
.btn-green {
  --tw-text-opacity: 1;
  color: rgb(255 255 255 / var(--tw-text-opacity));
  --tw-bg-opacity: 1;
  background-color: rgb(34 197 94 / var(--tw-bg-opacity));
}
.btn-green:hover {
  --tw-bg-opacity: 1;
  background-color: rgb(21 128 61 / var(--tw-bg-opacity));
}
```

### Dynamic Shortcuts (Regex Patterns)

Allow pattern-based shortcuts for dynamic class generation.

#### Configuration Format

```json
{
  "shortcuts": [
    {
      "btn": "py-2 px-4 font-semibold rounded-lg shadow-md"
    },
    {
      "pattern": "^btn-(.*)$",
      "template": "bg-${1}-400 text-${1}-100 py-2 px-4 rounded-lg"
    },
    {
      "pattern": "^card-(.*)$",
      "template": "bg-white rounded-lg shadow-${1} p-6"
    }
  ]
}
```

#### Usage

**HTML:**
```html
<button class="btn-green">Green Button</button>
<button class="btn-red">Red Button</button>
<div class="card-md">Card</div>
```

**Generated CSS:**
```css
.btn-green {
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
  padding-left: 1rem;
  padding-right: 1rem;
  --tw-bg-opacity: 1;
  background-color: rgb(74 222 128 / var(--tw-bg-opacity));
  border-radius: 0.5rem;
  --tw-text-opacity: 1;
  color: rgb(220 252 231 / var(--tw-text-opacity));
}

.btn-red {
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
  padding-left: 1rem;
  padding-right: 1rem;
  --tw-bg-opacity: 1;
  background-color: rgb(248 113 113 / var(--tw-bg-opacity));
  border-radius: 0.5rem;
  --tw-text-opacity: 1;
  color: rgb(254 226 226 / var(--tw-text-opacity));
}
```

## Feature 2: Compile Class Transformer

### Overview

Compile groups of classes into single optimized classes with generated names, reducing HTML class attribute size.

### Marker Syntax

Use `:hw:` prefix to mark classes for compilation (instead of UnoCSS's `:uno:`).

#### Usage

**HTML Input:**
```html
<div class=":hw: text-center sm:text-left">
  <div class=":hw: text-sm font-bold hover:text-red" />
</div>
```

**HTML Output:**
```html
<div class="hw-qlmcrp">
  <div class="hw-0qw2gr" />
</div>
```

**Generated CSS:**
```css
.hw-qlmcrp {
  text-align: center;
}
@media (min-width: 640px) {
  .hw-qlmcrp {
    text-align: left;
  }
}

.hw-0qw2gr {
  font-size: 0.875rem;
  line-height: 1.25rem;
  font-weight: 700;
}
.hw-0qw2gr:hover {
  --tw-text-opacity: 1;
  color: rgb(248 113 113 / var(--tw-text-opacity));
}
```

### Configuration

```json
{
  "compileClass": {
    "enabled": true,
    "trigger": ":hw:",
    "classPrefix": "hw-",
    "hashLength": 6,
    "hashAlgorithm": "murmur3"
  }
}
```

## Implementation Architecture

### 1. Configuration Schema

**File:** `src/config/schema.zig`

```zig
pub const ShortcutConfig = struct {
    /// Static shortcuts: map of name -> class string
    static: ?std.StringHashMap([]const u8) = null,

    /// Dynamic shortcuts: array of patterns
    dynamic: ?[]DynamicShortcut = null,
};

pub const DynamicShortcut = struct {
    /// Regex pattern to match
    pattern: []const u8,

    /// Template with ${1}, ${2} placeholders
    template: []const u8,
};

pub const CompileClassConfig = struct {
    /// Enable/disable compile class feature
    enabled: bool = false,

    /// Trigger string (default ":hw:")
    trigger: []const u8 = ":hw:",

    /// Prefix for generated classes (default "hw-")
    classPrefix: []const u8 = "hw-",

    /// Hash length for generated names
    hashLength: u8 = 6,

    /// Hash algorithm: "murmur3", "xxhash", "md5"
    hashAlgorithm: []const u8 = "murmur3",
};

pub const HeadwindConfig = struct {
    // ... existing config ...

    shortcuts: ?ShortcutConfig = null,
    compileClass: ?CompileClassConfig = null,
};
```

### 2. Shortcut Expander

**File:** `src/core/shortcut_expander.zig`

```zig
pub const ShortcutExpander = struct {
    allocator: std.mem.Allocator,
    static_shortcuts: std.StringHashMap([]const u8),
    dynamic_shortcuts: []DynamicShortcut,

    pub fn init(allocator: std.mem.Allocator, config: ShortcutConfig) !ShortcutExpander { ... }

    /// Expand a class name if it matches a shortcut
    pub fn expand(self: *ShortcutExpander, class: []const u8) !?[]const u8 {
        // 1. Check static shortcuts
        if (self.static_shortcuts.get(class)) |expansion| {
            return try self.allocator.dupe(u8, expansion);
        }

        // 2. Check dynamic shortcuts
        for (self.dynamic_shortcuts) |shortcut| {
            if (try self.matchPattern(class, shortcut.pattern)) |captures| {
                return try self.applyTemplate(shortcut.template, captures);
            }
        }

        return null;
    }

    fn matchPattern(self: *ShortcutExpander, input: []const u8, pattern: []const u8) !?[][]const u8 { ... }

    fn applyTemplate(self: *ShortcutExpander, template: []const u8, captures: [][]const u8) ![]const u8 { ... }
};
```

### 3. Compile Class Transformer

**File:** `src/transformer/compile_class.zig`

```zig
pub const CompileClassTransformer = struct {
    allocator: std.mem.Allocator,
    config: CompileClassConfig,
    class_cache: std.StringHashMap([]const u8), // Original -> Compiled name

    pub fn init(allocator: std.mem.Allocator, config: CompileClassConfig) !CompileClassTransformer { ... }

    /// Transform HTML content, replacing :hw: classes with compiled ones
    pub fn transform(self: *CompileClassTransformer, html: []const u8) ![]const u8 {
        // 1. Find all class attributes with :hw: trigger
        // 2. Extract the classes after :hw:
        // 3. Generate hash for the class combination
        // 4. Replace with compiled class name
        // 5. Store mapping for CSS generation
    }

    /// Generate a hash-based class name
    fn generateClassName(self: *CompileClassTransformer, classes: []const u8) ![]const u8 {
        const hash = try self.hashClasses(classes);
        return try std.fmt.allocPrint(
            self.allocator,
            "{s}{s}",
            .{ self.config.classPrefix, hash[0..self.config.hashLength] }
        );
    }

    fn hashClasses(self: *CompileClassTransformer, classes: []const u8) ![]const u8 {
        // Use murmur3 or xxhash for fast hashing
        return switch (self.config.hashAlgorithm) {
            "murmur3" => try self.murmur3Hash(classes),
            "xxhash" => try self.xxHash(classes),
            "md5" => try self.md5Hash(classes),
            else => try self.murmur3Hash(classes),
        };
    }
};
```

### 4. Integration Points

#### Scanner Integration

**File:** `src/scanner/class_scanner.zig`

```zig
pub const ClassScanner = struct {
    // ... existing fields ...
    shortcut_expander: ?*ShortcutExpander,
    compile_transformer: ?*CompileClassTransformer,

    pub fn scanClasses(self: *ClassScanner, content: []const u8) ![][]const u8 {
        var classes = std.ArrayList([]const u8).init(self.allocator);

        // 1. Apply compile class transformation if enabled
        const transformed_content = if (self.compile_transformer) |transformer|
            try transformer.transform(content)
        else
            content;

        // 2. Scan for classes
        const raw_classes = try self.extractClasses(transformed_content);

        // 3. Expand shortcuts
        for (raw_classes) |class| {
            if (self.shortcut_expander) |expander| {
                if (try expander.expand(class)) |expanded| {
                    // Split expanded string and add all classes
                    var iter = std.mem.tokenize(u8, expanded, " ");
                    while (iter.next()) |utility| {
                        try classes.append(try self.allocator.dupe(u8, utility));
                    }
                    self.allocator.free(expanded);
                    continue;
                }
            }

            // No expansion, add as-is
            try classes.append(class);
        }

        return classes.toOwnedSlice();
    }
};
```

## Example Configurations

### Basic Shortcuts

**headwind.json:**
```json
{
  "shortcuts": {
    "btn": "py-2 px-4 font-semibold rounded-lg shadow-md",
    "btn-primary": "btn bg-blue-500 text-white hover:bg-blue-700",
    "btn-secondary": "btn bg-gray-500 text-white hover:bg-gray-700",
    "card": "bg-white rounded-lg shadow-md p-6",
    "badge": "px-2 py-1 text-xs font-bold rounded-full"
  }
}
```

### Advanced Shortcuts with Patterns

**headwind.json:**
```json
{
  "shortcuts": [
    {
      "btn": "py-2 px-4 font-semibold rounded-lg shadow-md"
    },
    {
      "pattern": "^btn-(.*)$",
      "template": "bg-${1}-500 text-white hover:bg-${1}-700 py-2 px-4 rounded-lg"
    },
    {
      "pattern": "^badge-(.*)$",
      "template": "bg-${1}-100 text-${1}-800 px-2 py-1 text-xs rounded-full"
    },
    {
      "pattern": "^icon-(.*)$",
      "template": "w-${1} h-${1} inline-block"
    }
  ]
}
```

### Compile Class Configuration

**headwind.json:**
```json
{
  "compileClass": {
    "enabled": true,
    "trigger": ":hw:",
    "classPrefix": "hw-",
    "hashLength": 7,
    "hashAlgorithm": "murmur3"
  }
}
```

## Testing Strategy

### Unit Tests

```zig
test "static shortcut expansion" {
    const allocator = std.testing.allocator;

    var shortcuts = std.StringHashMap([]const u8).init(allocator);
    defer shortcuts.deinit();
    try shortcuts.put("btn", "py-2 px-4 rounded");

    const config = ShortcutConfig{ .static = shortcuts };
    var expander = try ShortcutExpander.init(allocator, config);
    defer expander.deinit();

    const expanded = try expander.expand("btn");
    defer if (expanded) |e| allocator.free(e);

    try std.testing.expectEqualStrings("py-2 px-4 rounded", expanded.?);
}

test "dynamic shortcut expansion" {
    const allocator = std.testing.allocator;

    const dynamic = [_]DynamicShortcut{
        .{ .pattern = "^btn-(.*)$", .template = "bg-${1}-500 text-white" },
    };

    const config = ShortcutConfig{ .dynamic = &dynamic };
    var expander = try ShortcutExpander.init(allocator, config);
    defer expander.deinit();

    const expanded = try expander.expand("btn-red");
    defer if (expanded) |e| allocator.free(e);

    try std.testing.expectEqualStrings("bg-red-500 text-white", expanded.?);
}

test "compile class hash generation" {
    const allocator = std.testing.allocator;

    const config = CompileClassConfig{
        .enabled = true,
        .trigger = ":hw:",
        .classPrefix = "hw-",
        .hashLength = 6,
    };

    var transformer = try CompileClassTransformer.init(allocator, config);
    defer transformer.deinit();

    const class_name = try transformer.generateClassName("text-center sm:text-left");
    defer allocator.free(class_name);

    try std.testing.expect(std.mem.startsWith(u8, class_name, "hw-"));
    try std.testing.expectEqual(@as(usize, 9), class_name.len); // "hw-" + 6 chars
}
```

## Performance Considerations

1. **Shortcut Cache**: Cache expanded shortcuts to avoid repeated regex matching
2. **Hash Function**: Use fast non-cryptographic hash (murmur3, xxhash)
3. **Lazy Expansion**: Only expand shortcuts when actually used
4. **Compile Map**: Store compile class mappings for incremental builds

## Migration Path

### Phase 1: Static Shortcuts
- Implement basic static shortcut support
- Add configuration schema
- Integrate with scanner

### Phase 2: Dynamic Shortcuts
- Add regex pattern matching
- Implement template substitution
- Add caching layer

### Phase 3: Compile Class
- Implement :hw: marker detection
- Add hash generation
- HTML transformation
- CSS output mapping

### Phase 4: Optimization
- Add caching for performance
- Incremental compilation support
- Source maps for debugging

## CLI Usage

```bash
# Generate CSS with shortcuts
headwind build -i input.html -o output.css --config headwind.json

# Enable compile class transformation
headwind build -i input.html -o output.css --compile-classes

# Generate with both features
headwind build -i input.html -o output.css --shortcuts --compile-classes
```

## Documentation Examples

### Quick Start

```html
<!-- Define shortcuts in headwind.json -->
{
  "shortcuts": {
    "btn": "px-4 py-2 rounded bg-blue-500 text-white hover:bg-blue-600"
  }
}

<!-- Use in HTML -->
<button class="btn">Click me</button>

<!-- Or use compile mode for smaller HTML -->
<button class=":hw: px-4 py-2 rounded bg-blue-500 text-white hover:bg-blue-600">
  Click me
</button>

<!-- Output HTML -->
<button class="hw-a1b2c3">Click me</button>

<!-- Output CSS -->
.hw-a1b2c3 {
  padding-left: 1rem;
  padding-right: 1rem;
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
  border-radius: 0.25rem;
  background-color: rgb(59 130 246);
  color: rgb(255 255 255);
}
.hw-a1b2c3:hover {
  background-color: rgb(37 99 235);
}
```

## Future Enhancements

1. **Nested Shortcuts**: Support shortcuts that reference other shortcuts
2. **Conditional Shortcuts**: Platform-specific or theme-specific shortcuts
3. **ESLint Plugin**: Validate shortcut usage
4. **VSCode Extension**: Autocomplete for shortcuts
5. **Source Maps**: Map compiled classes back to original for debugging
6. **Tree Shaking**: Only include used shortcuts in output

## Status

**Current**: Specification phase
**Next Steps**:
1. Implement configuration schema
2. Create shortcut expander
3. Add scanner integration
4. Implement compile class transformer

**Estimated Effort**: 2-3 weeks for full implementation
