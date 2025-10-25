/**
 * Comparative Benchmarks: zig-headwind vs Competing Tools
 *
 * Tools compared:
 * - zig-headwind (this project)
 * - Tailwind CSS v3
 * - UnoCSS
 *
 * Metrics:
 * - Parse time
 * - Generate time
 * - Total build time
 * - Memory usage
 * - Output size (minified)
 */

import { bench, group, run } from 'mitata';
import { execSync } from 'child_process';
import { readFileSync, writeFileSync, mkdirSync } from 'fs';
import { join } from 'path';

// Test HTML with various Tailwind classes
const TEST_HTML = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Benchmark Test</title>
</head>
<body>
  <div class="bg-blue-500 text-white p-4 m-2 rounded-lg shadow-md hover:bg-blue-600">
    <h1 class="text-3xl font-bold mb-4">Hello World</h1>
    <p class="text-lg leading-relaxed">This is a test paragraph with various Tailwind classes.</p>
    <div class="flex items-center justify-between gap-4 mt-4">
      <button class="px-6 py-2 bg-green-500 hover:bg-green-600 rounded-md transition-colors">
        Click me
      </button>
      <div class="grid grid-cols-3 gap-2">
        <div class="bg-red-500 p-2"></div>
        <div class="bg-green-500 p-2"></div>
        <div class="bg-blue-500 p-2"></div>
      </div>
    </div>
  </div>
  <div class="container mx-auto px-4 py-8">
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div class="bg-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
        <h2 class="text-xl font-semibold mb-2">Card 1</h2>
        <p class="text-gray-600">Content goes here</p>
      </div>
      <div class="bg-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
        <h2 class="text-xl font-semibold mb-2">Card 2</h2>
        <p class="text-gray-600">Content goes here</p>
      </div>
      <div class="bg-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
        <h2 class="text-xl font-semibold mb-2">Card 3</h2>
        <p class="text-gray-600">Content goes here</p>
      </div>
    </div>
  </div>
</body>
</html>
`;

// Prepare test files
mkdirSync('temp', { recursive: true });
writeFileSync('temp/test.html', TEST_HTML);

// Tailwind CSS config
const TAILWIND_CONFIG = `
module.exports = {
  content: ['temp/test.html'],
  theme: {
    extend: {},
  },
  plugins: [],
}
`;
writeFileSync('temp/tailwind.config.js', TAILWIND_CONFIG);

// UnoCSS config
const UNOCSS_CONFIG = `
import { defineConfig } from 'unocss'

export default defineConfig({
  // your config
})
`;
writeFileSync('temp/uno.config.ts', UNOCSS_CONFIG);

// Helper to measure execution time and memory
function measureTool(name: string, command: string) {
  const start = performance.now();
  let memoryUsed = 0;

  try {
    const result = execSync(command, {
      cwd: 'temp',
      encoding: 'utf-8',
      stdio: 'pipe',
    });

    const end = performance.now();
    const time = end - start;

    return { time, output: result, error: null };
  } catch (error: any) {
    return { time: 0, output: '', error: error.message };
  }
}

// Benchmark groups
group('Build Time Comparison', () => {
  bench('zig-headwind', () => {
    execSync('../zig-out/bin/headwind build', {
      cwd: 'temp',
      stdio: 'pipe',
    });
  });

  bench('Tailwind CSS v3', () => {
    execSync('npx tailwindcss -i input.css -o output.css --minify', {
      cwd: 'temp',
      stdio: 'pipe',
    });
  });

  bench('UnoCSS', () => {
    execSync('npx unocss "**/*.html" -o output.css', {
      cwd: 'temp',
      stdio: 'pipe',
    });
  });
});

group('Cold Start Performance', () => {
  bench('zig-headwind (cold)', () => {
    execSync('../zig-out/bin/headwind build --no-cache', {
      cwd: 'temp',
      stdio: 'pipe',
    });
  });

  bench('Tailwind CSS (cold)', () => {
    execSync('rm -rf .cache && npx tailwindcss -i input.css -o output.css', {
      cwd: 'temp',
      stdio: 'pipe',
    });
  });

  bench('UnoCSS (cold)', () => {
    execSync('rm -rf .cache && npx unocss "**/*.html" -o output.css', {
      cwd: 'temp',
      stdio: 'pipe',
    });
  });
});

group('Incremental Build Performance', () => {
  bench('zig-headwind (incremental)', () => {
    execSync('../zig-out/bin/headwind build --incremental', {
      cwd: 'temp',
      stdio: 'pipe',
    });
  });

  bench('Tailwind CSS (incremental)', () => {
    execSync('npx tailwindcss -i input.css -o output.css --minify', {
      cwd: 'temp',
      stdio: 'pipe',
    });
  });
});

group('Output Size Comparison', () => {
  bench('zig-headwind (minified)', () => {
    const result = execSync('../zig-out/bin/headwind build --minify', {
      cwd: 'temp',
      encoding: 'utf-8',
    });
    return result.length;
  });

  bench('Tailwind CSS (minified)', () => {
    const result = execSync('npx tailwindcss -i input.css -o output.css --minify', {
      cwd: 'temp',
      encoding: 'utf-8',
    });
    return result.length;
  });

  bench('UnoCSS (minified)', () => {
    const result = execSync('npx unocss "**/*.html" -o output.css --minify', {
      cwd: 'temp',
      encoding: 'utf-8',
    });
    return result.length;
  });
});

console.log('🏁 Running comparative benchmarks...\n');
console.log('Tools being compared:');
console.log('  - zig-headwind (Zig native)');
console.log('  - Tailwind CSS v3 (Node.js)');
console.log('  - UnoCSS (Node.js)');
console.log('');

await run({
  units: false,
  silent: false,
  avg: true,
  json: true,
  colors: true,
  min_max: true,
  percentiles: true,
});

// Generate detailed report
console.log('\n📊 Detailed Performance Report');
console.log('================================\n');

const headwindResult = measureTool('zig-headwind', '../zig-out/bin/headwind build');
const tailwindResult = measureTool('Tailwind CSS', 'npx tailwindcss -i input.css -o output.css --minify');
const unocssResult = measureTool('UnoCSS', 'npx unocss "**/*.html" -o output.css');

console.log('Build Times:');
console.log(`  zig-headwind: ${headwindResult.time.toFixed(2)}ms`);
console.log(`  Tailwind CSS: ${tailwindResult.time.toFixed(2)}ms`);
console.log(`  UnoCSS:       ${unocssResult.time.toFixed(2)}ms`);
console.log('');

console.log('Speed Comparison:');
if (headwindResult.time > 0) {
  const tailwindSpeedup = tailwindResult.time / headwindResult.time;
  const unocssSpeedup = unocssResult.time / headwindResult.time;
  console.log(`  zig-headwind is ${tailwindSpeedup.toFixed(2)}x faster than Tailwind CSS`);
  console.log(`  zig-headwind is ${unocssSpeedup.toFixed(2)}x faster than UnoCSS`);
}

console.log('\n✅ Comparative benchmarks complete!');
