# Test Patterns & Best Practices

## Overview

This document describes the testing patterns, best practices, and conventions used in the zig-headwind test suite.

---

## Table of Contents

1. [Test Organization](#test-organization)
2. [Naming Conventions](#naming-conventions)
3. [Test Structure Patterns](#test-structure-patterns)
4. [Common Test Patterns](#common-test-patterns)
5. [Edge Case Testing](#edge-case-testing)
6. [Performance Testing](#performance-testing)
7. [Integration Testing](#integration-testing)
8. [Best Practices](#best-practices)

---

## Test Organization

### Directory Structure

```
test/
├── unit/                          # Unit tests
│   ├── parser/                    # Parser-specific tests
│   ├── generator/                 # Generator module tests
│   ├── utils/                     # Utility function tests
│   └── edge_cases/                # Comprehensive edge case tests
├── integration/                   # Integration tests
├── e2e/                          # End-to-end tests
├── benchmark/                     # Performance benchmarks
└── test_runner.zig               # Main test runner
```

### File Naming

- **Unit tests**: `{module}_test.zig`
- **Integration tests**: `{feature}_integration_test.zig`
- **E2E tests**: `{workflow}_test.zig`
- **Benchmarks**: `{feature}.bench.ts` (TypeScript/Bun)

---

## Naming Conventions

### Test Names

Use descriptive names that explain what is being tested:

```zig
✅ GOOD:
test "parse simple utility class"
test "generate CSS with OKLCH colors"
test "edge case: empty string input"
test "integration: parser + generator workflow"

❌ BAD:
test "test1"
test "parsing"
test "works"
```

### Test Groups

Group related tests together:

```zig
// ============================================================================
// Background Color Tests
// ============================================================================

test "background color with OKLCH" { }
test "background color with arbitrary value" { }
test "background special colors" { }

// ============================================================================
// Background Attachment Tests
// ============================================================================

test "background attachment values" { }
```

---

## Test Structure Patterns

### Pattern 1: Basic Unit Test

**Use case**: Testing a single function with one input/output

```zig
test "parse simple utility class" {
    const allocator = testing.allocator;

    // Setup
    var parsed = try class_parser.parseClass(allocator, "bg-blue-500");
    defer parsed.deinit(allocator);

    // Verify
    try testing.expectEqualStrings("bg-blue-500", parsed.utility);
    try testing.expect(!parsed.is_arbitrary);
    try testing.expect(parsed.variants.len == 0);
}
```

### Pattern 2: Parameterized Test (Array Iteration)

**Use case**: Testing the same logic with multiple inputs

```zig
test "background attachment values" {
    const allocator = testing.allocator;

    const attachments = [_][]const u8{
        "fixed",
        "local",
        "scroll",
    };

    for (attachments) |attachment| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "bg-{s}", .{attachment});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try backgrounds.generateBgAttachment(&generator, &parsed, attachment);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "background-attachment") != null);
    }
}
```

### Pattern 3: Generator Test with Verification

**Use case**: Testing CSS generation and verifying output

```zig
test "background color with OKLCH" {
    const allocator = testing.allocator;

    // 1. Setup generator
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    // 2. Parse class
    var parsed = try class_parser.parseClass(allocator, "bg-blue-500");
    defer parsed.deinit(allocator);

    // 3. Generate CSS
    try backgrounds.generateBgColor(&generator, &parsed, "blue-500");

    // 4. Get output
    const css = try generator.generate();
    defer allocator.free(css);

    // 5. Verify
    try testing.expect(std.mem.indexOf(u8, css, "background-color") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch(") != null);
}
```

### Pattern 4: Error Testing

**Use case**: Verifying that errors are properly returned

```zig
test "edge case: empty string" {
    const allocator = testing.allocator;

    const result = class_parser.parseClass(allocator, "");
    try testing.expectError(error.InvalidClassName, result);
}
```

### Pattern 5: Struct-Based Parameterization

**Use case**: Testing with complex input/output pairs

```zig
test "background clip values" {
    const allocator = testing.allocator;

    const clips = [_]struct { input: []const u8, expected: []const u8 }{
        .{ .input = "border", .expected = "border-box" },
        .{ .input = "padding", .expected = "padding-box" },
        .{ .input = "content", .expected = "content-box" },
        .{ .input = "text", .expected = "text" },
    };

    for (clips) |clip| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "bg-clip-{s}", .{clip.input});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try backgrounds.generateBgClip(&generator, &parsed, clip.input);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "background-clip") != null);
        try testing.expect(std.mem.indexOf(u8, css, clip.expected) != null);
    }
}
```

---

## Common Test Patterns

### Memory Management Pattern

**Always use defer for cleanup:**

```zig
test "proper memory management" {
    const allocator = testing.allocator;

    // Parse
    var parsed = try class_parser.parseClass(allocator, "bg-blue-500");
    defer parsed.deinit(allocator);  // ✅ Always defer cleanup

    // Generator
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();  // ✅ Always defer cleanup

    // Dynamic strings
    const class_name = try std.fmt.allocPrint(allocator, "bg-{s}", .{"blue-500"});
    defer allocator.free(class_name);  // ✅ Always defer cleanup

    const css = try generator.generate();
    defer allocator.free(css);  // ✅ Always defer cleanup
}
```

### Assertion Pattern

**Use appropriate assertions:**

```zig
// Equality checks
try testing.expectEqual(expected, actual);
try testing.expectEqualStrings("expected", actual);

// Boolean checks
try testing.expect(condition);

// Error checks
try testing.expectError(error.SomeError, result);

// String search
try testing.expect(std.mem.indexOf(u8, haystack, "needle") != null);

// Count occurrences
const count = std.mem.count(u8, haystack, "needle");
try testing.expect(count == 1);
```

---

## Edge Case Testing

### Categories of Edge Cases

1. **Input Validation**
   - Empty strings
   - Whitespace-only
   - Null bytes
   - Very long inputs

2. **Boundary Values**
   - Maximum/minimum numbers
   - Zero values
   - Negative values

3. **Special Characters**
   - Unicode (emoji, combining marks, RTL)
   - Escape sequences
   - Quotes and brackets

4. **Malformed Input**
   - Unclosed brackets
   - Invalid syntax
   - Conflicting values

### Edge Case Test Pattern

```zig
test "edge case: {description}" {
    const allocator = testing.allocator;

    // 1. Define edge case input(s)
    const edge_cases = [_][]const u8{
        "input1",
        "input2",
        "input3",
    };

    // 2. Test each case
    for (edge_cases) |input| {
        // 3. Execute
        const result = someFunction(input);

        // 4. Verify graceful handling
        if (result) |value| {
            // Success case
            try testing.expect(value.isValid());
        } else |err| {
            // Error case - verify expected error
            try testing.expect(err == error.ExpectedError);
        }
    }
}
```

---

## Performance Testing

### Using mitata + Bun (TypeScript)

**Pattern for benchmarks:**

```typescript
import { bench, group, run } from 'mitata';

group('Feature Name', () => {
  bench('Test case 1', () => {
    // Code to benchmark
  });

  bench('Test case 2', () => {
    // Code to benchmark
  });
});

await run({
  units: false,
  silent: false,
  avg: true,
  colors: true,
  min_max: true,
  percentiles: true,
});
```

### Benchmark Categories

1. **Parser benchmarks**: Test parsing speed
2. **Generator benchmarks**: Test CSS generation speed
3. **Full build benchmarks**: End-to-end performance
4. **Comparison benchmarks**: vs Tailwind CSS, UnoCSS

### Running Benchmarks

```bash
# All benchmarks
bun run benchmarks/suite.ts

# Specific benchmark
bun run benchmarks/parser.bench.ts

# Comparative benchmarks
bun run benchmarks/compare-tools.bench.ts
```

---

## Integration Testing

### Integration Test Pattern

**Tests interaction between multiple modules:**

```zig
test "integration: parse and generate simple utility" {
    const allocator = testing.allocator;

    // 1. Parse (Parser module)
    var parsed = try class_parser.parseClass(allocator, "bg-blue-500");
    defer parsed.deinit(allocator);

    // 2. Generate (Generator module)
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    try headwind.backgrounds.generateBgColor(&generator, &parsed, "blue-500");

    // 3. Verify complete workflow
    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, ".bg-blue-500") != null);
    try testing.expect(std.mem.indexOf(u8, css, "background-color") != null);
    try testing.expect(std.mem.indexOf(u8, css, "oklch(") != null);
}
```

### E2E Test Pattern

**Tests complete user workflows:**

```zig
test "e2e: complete CSS generation workflow" {
    const allocator = testing.allocator;

    // 1. Define realistic HTML classes
    const html_classes = [_][]const u8{
        "bg-blue-500",
        "text-white",
        "p-4",
        "rounded-lg",
        "hover:bg-blue-600",
    };

    // 2. Initialize generator
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    // 3. Process each class (simulating real workflow)
    for (html_classes) |class| {
        var parsed = try class_parser.parseClass(allocator, class);
        defer parsed.deinit(allocator);

        // Dispatch to appropriate generator
        // (simplified for example)
    }

    // 4. Generate final CSS
    const css = try generator.generate();
    defer allocator.free(css);

    // 5. Verify complete output
    try testing.expect(css.len > 0);
    try testing.expect(std.mem.indexOf(u8, css, "background-color") != null);
    try testing.expect(std.mem.indexOf(u8, css, ":hover") != null);
}
```

---

## Best Practices

### 1. Test Independence

**Each test should be independent:**

```zig
✅ GOOD: Each test creates its own generator
test "test 1" {
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();
    // ... test code
}

test "test 2" {
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();
    // ... test code
}

❌ BAD: Sharing state between tests
var shared_generator: CSSGenerator = undefined;  // Don't do this!
```

### 2. Clear Test Sections

**Use comments to separate test sections:**

```zig
test "complex workflow" {
    const allocator = testing.allocator;

    // Setup
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    // Parse input
    var parsed = try class_parser.parseClass(allocator, "bg-blue-500");
    defer parsed.deinit(allocator);

    // Generate CSS
    try backgrounds.generateBgColor(&generator, &parsed, "blue-500");

    // Verify output
    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(css.len > 0);
}
```

### 3. Meaningful Assertions

**Assert what matters:**

```zig
✅ GOOD: Specific checks
try testing.expect(std.mem.indexOf(u8, css, "background-color") != null);
try testing.expect(std.mem.indexOf(u8, css, "oklch(") != null);

❌ BAD: Vague checks
try testing.expect(css.len > 0);  // Too general, doesn't verify correctness
```

### 4. Error Messages

**Use descriptive test names that serve as error messages:**

```zig
✅ GOOD:
test "background color should use OKLCH format" { }

❌ BAD:
test "bg color" { }
```

### 5. Test Coverage

**Cover these cases for each feature:**

- ✅ Happy path (normal usage)
- ✅ Edge cases (boundary values)
- ✅ Error cases (invalid input)
- ✅ Integration (with other modules)

### 6. Performance Considerations

**Don't create excessive allocations in tests:**

```zig
✅ GOOD:
const data = [_][]const u8{ "a", "b", "c" };
for (data) |item| { /* test */ }

❌ BAD:
for (0..1000000) |i| {  // Don't do this unless testing performance!
    const str = try std.fmt.allocPrint(...);  // Excessive allocations
}
```

### 7. Documentation

**Add doc comments for complex tests:**

```zig
/// Tests that the parser correctly handles deeply nested variants
/// This is important for ensuring no stack overflow with pathological input
test "parser handles 100 levels of variant nesting" {
    // ... test code
}
```

---

## Quick Reference

### Test File Template

```zig
const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const module = headwind.module_name;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Feature Group 1
// ============================================================================

test "feature 1 test case 1" {
    const allocator = testing.allocator;

    // Setup
    var generator = CSSGenerator.init(allocator);
    defer generator.deinit();

    var parsed = try class_parser.parseClass(allocator, "class-name");
    defer parsed.deinit(allocator);

    // Execute
    try module.generateSomething(&generator, &parsed, "value");

    // Verify
    const css = try generator.generate();
    defer allocator.free(css);

    try testing.expect(std.mem.indexOf(u8, css, "expected") != null);
}

// ============================================================================
// Feature Group 2
// ============================================================================

test "feature 2 test case 1" {
    // ... similar structure
}
```

### Benchmark File Template

```typescript
import { bench, group, run } from 'mitata';
import { execSync } from 'child_process';

group('Feature Name', () => {
  bench('Benchmark case 1', () => {
    execSync('../zig-out/bin/headwind ...', { stdio: 'pipe' });
  });

  bench('Benchmark case 2', () => {
    execSync('../zig-out/bin/headwind ...', { stdio: 'pipe' });
  });
});

await run({
  units: false,
  avg: true,
  colors: true,
  min_max: true,
  percentiles: true,
});
```

---

## Summary

**Key Principles:**

1. ✅ **Independence**: Tests don't depend on each other
2. ✅ **Clarity**: Test names explain what's being tested
3. ✅ **Coverage**: Test happy path, edge cases, and errors
4. ✅ **Memory**: Always use defer for cleanup
5. ✅ **Assertions**: Verify specific behavior, not general conditions
6. ✅ **Organization**: Group related tests together
7. ✅ **Documentation**: Comment complex logic

**When in doubt:**
- Look at existing tests in `test/unit/generator/backgrounds_test.zig`
- Follow the patterns in this document
- Keep tests simple and focused

---

*Last Updated: October 25, 2025*
*Test Suite Version: 2.0 (Phase 6 Complete)*
