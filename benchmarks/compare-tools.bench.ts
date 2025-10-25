/**
 * Comparative Benchmarks: zig-headwind vs Competing Tools
 *
 * Tools compared:
 * - zig-headwind (this project)
 * - Tailwind CSS v3 (Node.js)
 * - UnoCSS
 *
 * Metrics:
 * - Parse time
 * - Generate time
 * - Total build time
 * - Output size (minified)
 */

import { bench, group, run } from 'mitata';
import { execSync } from 'child_process';
import { readFileSync, writeFileSync, mkdirSync, statSync, rmSync } from 'fs';

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
  content: ['./temp/**/*.html'],
  theme: {
    extend: {},
  },
  plugins: [],
}
`;
writeFileSync('tailwind.config.js', TAILWIND_CONFIG);

// Tailwind input CSS
const TAILWIND_INPUT = `@tailwind base; @tailwind components; @tailwind utilities;`;
writeFileSync('temp/input.css', TAILWIND_INPUT);

// UnoCSS config
const UNO_CONFIG = `
import { defineConfig, presetUno } from 'unocss';

export default defineConfig({
  presets: [presetUno()],
});
`;
writeFileSync('uno.config.ts', UNO_CONFIG);

console.log('🏁 Running comparative benchmarks...\n');
console.log('Tools being compared:');
console.log('  - zig-headwind (Zig native)');
console.log('  - Tailwind CSS v3 (Node.js)');
console.log('  - UnoCSS (Node.js)\n');

const results: Record<string, number> = {};

group('Build Time Comparison', () => {
  bench('zig-headwind', () => {
    execSync('../zig-out/bin/headwind build temp/test.html -o temp/headwind-output.css', {
      stdio: 'pipe',
    });
  });

  bench('Tailwind CSS v3', () => {
    execSync('./node_modules/.bin/tailwindcss -i temp/input.css -o temp/tailwind-output.css --minify', {
      stdio: 'pipe',
    });
  });

  bench('UnoCSS', () => {
    execSync('./node_modules/.bin/unocss temp/**/*.html -o temp/uno-output.css --minify', {
      stdio: 'pipe',
    });
  });
});

group('Cold Start Performance', () => {
  bench('zig-headwind (cold)', () => {
    try {
      rmSync('temp/headwind-output.css', { force: true });
    } catch {}
    execSync('../zig-out/bin/headwind build temp/test.html -o temp/headwind-output.css', {
      stdio: 'pipe',
    });
  });

  bench('Tailwind CSS (cold)', () => {
    try {
      rmSync('temp/tailwind-output.css', { force: true });
      rmSync('.tailwindcss', { recursive: true, force: true });
    } catch {}
    execSync('./node_modules/.bin/tailwindcss -i temp/input.css -o temp/tailwind-output.css', {
      stdio: 'pipe',
    });
  });

  bench('UnoCSS (cold)', () => {
    try {
      rmSync('temp/uno-output.css', { force: true });
      rmSync('.uno.cache', { recursive: true, force: true });
    } catch {}
    execSync('./node_modules/.bin/unocss temp/**/*.html -o temp/uno-output.css', {
      stdio: 'pipe',
    });
  });
});

await run({
  units: false,
  silent: false,
  avg: true,
  json: false,
  colors: true,
  min_max: true,
  percentiles: true,
});

// Measure output sizes
console.log('\n📊 Output Size Comparison');
console.log('================================\n');

try {
  const headwindSize = statSync('temp/headwind-output.css').size;
  const tailwindSize = statSync('temp/tailwind-output.css').size;
  const unoSize = statSync('temp/uno-output.css').size;

  console.log(`zig-headwind: ${(headwindSize / 1024).toFixed(2)} KB`);
  console.log(`Tailwind CSS: ${(tailwindSize / 1024).toFixed(2)} KB`);
  console.log(`UnoCSS:       ${(unoSize / 1024).toFixed(2)} KB\n`);

  const smallest = Math.min(headwindSize, tailwindSize, unoSize);
  console.log('Winner (smallest):');
  if (headwindSize === smallest) console.log('  🏆 zig-headwind');
  else if (tailwindSize === smallest) console.log('  🏆 Tailwind CSS');
  else console.log('  🏆 UnoCSS');
} catch (e) {
  console.log('Could not measure output sizes');
}

console.log('\n✅ Comparative benchmarks complete!');

// Cleanup
rmSync('temp', { recursive: true, force: true });
rmSync('tailwind.config.js', { force: true });
rmSync('uno.config.ts', { force: true });
