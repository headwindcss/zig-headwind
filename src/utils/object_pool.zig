const std = @import("std");

/// Generic object pool for reducing allocations
/// Reuses objects instead of constantly allocating/freeing
pub fn ObjectPool(comptime T: type) type {
    return struct {
        const Self = @This();
        const PoolEntry = struct {
            object: T,
            in_use: bool,
        };

        allocator: std.mem.Allocator,
        pool: std.ArrayList(PoolEntry),
        high_water_mark: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .allocator = allocator,
                .pool = std.ArrayList(PoolEntry).init(allocator),
                .high_water_mark = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.pool.deinit();
        }

        /// Acquire an object from the pool
        /// Returns a pointer to a pooled object or creates a new one
        pub fn acquire(self: *Self) !*T {
            // Try to find an unused object
            for (self.pool.items) |*entry| {
                if (!entry.in_use) {
                    entry.in_use = true;
                    return &entry.object;
                }
            }

            // No free objects, create a new one
            const entry = PoolEntry{
                .object = undefined,
                .in_use = true,
            };
            try self.pool.append(entry);
            self.high_water_mark = @max(self.high_water_mark, self.pool.items.len);

            return &self.pool.items[self.pool.items.len - 1].object;
        }

        /// Release an object back to the pool
        pub fn release(self: *Self, object: *T) void {
            for (self.pool.items) |*entry| {
                if (&entry.object == object) {
                    entry.in_use = false;
                    return;
                }
            }
        }

        /// Get pool statistics
        pub fn stats(self: *Self) struct { total: usize, in_use: usize, high_water: usize } {
            var in_use_count: usize = 0;
            for (self.pool.items) |entry| {
                if (entry.in_use) in_use_count += 1;
            }
            return .{
                .total = self.pool.items.len,
                .in_use = in_use_count,
                .high_water = self.high_water_mark,
            };
        }
    };
}

test "ObjectPool basic operations" {
    const TestStruct = struct {
        value: i32,
    };

    var pool = ObjectPool(TestStruct).init(std.testing.allocator);
    defer pool.deinit();

    // Acquire first object
    const obj1 = try pool.acquire();
    obj1.value = 42;
    try std.testing.expectEqual(@as(i32, 42), obj1.value);

    // Acquire second object
    const obj2 = try pool.acquire();
    obj2.value = 100;

    // Pool should have 2 objects
    const pool_stats = pool.stats();
    try std.testing.expectEqual(@as(usize, 2), pool_stats.total);
    try std.testing.expectEqual(@as(usize, 2), pool_stats.in_use);

    // Release first object
    pool.release(obj1);

    // Pool should still have 2 objects, but only 1 in use
    const stats_after_release = pool.stats();
    try std.testing.expectEqual(@as(usize, 2), stats_after_release.total);
    try std.testing.expectEqual(@as(usize, 1), stats_after_release.in_use);

    // Acquire again - should reuse released object
    const obj3 = try pool.acquire();
    const stats_after_reacquire = pool.stats();
    try std.testing.expectEqual(@as(usize, 2), stats_after_reacquire.total);
}
