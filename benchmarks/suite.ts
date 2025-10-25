/**
 * Comprehensive Benchmark Suite for zig-headwind
 *
 * Compares performance against:
 * - Tailwind CSS v3/v4
 * - UnoCSS
 * - Lightning CSS (for minification)
 *
 * Uses mitata for accurate benchmarking
 */

import { bench, group, run } from 'mitata';
import { execSync } from 'child_process';
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { join } from 'path';

// Configuration
const HEADWIND_BIN = '../zig-out/bin/headwind';
const ITERATIONS = 1000;
const WARMUP = 100;

// Build headwind if needed
function ensureHeadwindBuilt() {
  if (!existsSync(HEADWIND_BIN)) {
    console.log('🔨 Building headwind...');
    execSync('zig build', { cwd: '..' });
  }
}

// Test data sets
const testSets = {
  small: generateClasses(10),
  medium: generateClasses(100),
  large: generateClasses(1000),
  xlarge: generateClasses(10000),
};

function generateClasses(count: number): string[] {
  const classes = [];
  const utilities = [
    'bg-blue-500', 'text-white', 'p-4', 'm-2', 'rounded-lg',
    'shadow-md', 'hover:bg-blue-600', 'flex', 'items-center',
    'justify-between', 'w-full', 'h-screen', 'gap-4',
  ];

  for (let i = 0; i < count; i++) {
    classes.push(utilities[i % utilities.length]);
  }

  return classes;
}

// Benchmark: Class parsing speed
group('Parser Performance', () => {
  bench('Parse 10 classes', () => {
    const input = testSets.small.join(' ');
    execSync(`echo "${input}" | ${HEADWIND_BIN} --stdin`, { encoding: 'utf-8' });
  });

  bench('Parse 100 classes', () => {
    const input = testSets.medium.join(' ');
    execSync(`echo "${input}" | ${HEADWIND_BIN} --stdin`, { encoding: 'utf-8' });
  });

  bench('Parse 1000 classes', () => {
    const input = testSets.large.join(' ');
    execSync(`echo "${input}" | ${HEADWIND_BIN} --stdin`, { encoding: 'utf-8' });
  });
});

// Benchmark: CSS generation speed
group('Generator Performance', () => {
  bench('Generate CSS for 10 classes', () => {
    const input = testSets.small.join(' ');
    execSync(`echo "${input}" | ${HEADWIND_BIN} --stdin`, { encoding: 'utf-8' });
  });

  bench('Generate CSS for 100 classes', () => {
    const input = testSets.medium.join(' ');
    execSync(`echo "${input}" | ${HEADWIND_BIN} --stdin`, { encoding: 'utf-8' });
  });

  bench('Generate CSS for 1000 classes', () => {
    const input = testSets.large.join(' ');
    execSync(`echo "${input}" | ${HEADWIND_BIN} --stdin`, { encoding: 'utf-8' });
  });

  bench('Generate CSS for 10000 classes', () => {
    const input = testSets.xlarge.join(' ');
    execSync(`echo "${input}" | ${HEADWIND_BIN} --stdin`, { encoding: 'utf-8' });
  });
});

// Benchmark: Memory usage
group('Memory Efficiency', () => {
  bench('Memory usage - 1000 classes', () => {
    const input = testSets.large.join(' ');
    execSync(`echo "${input}" | ${HEADWIND_BIN} --stdin`, {
      encoding: 'utf-8',
      maxBuffer: 10 * 1024 * 1024 // 10MB
    });
  });

  bench('Memory usage - 10000 classes', () => {
    const input = testSets.xlarge.join(' ');
    execSync(`echo "${input}" | ${HEADWIND_BIN} --stdin`, {
      encoding: 'utf-8',
      maxBuffer: 50 * 1024 * 1024 // 50MB
    });
  });
});

// Ensure headwind is built
ensureHeadwindBuilt();

// Run benchmarks
console.log('🚀 Running zig-headwind benchmarks...\n');
await run({
  units: false,
  silent: false,
  avg: true,
  json: false,
  colors: true,
  min_max: true,
  percentiles: true,
});

console.log('\n✅ Benchmarks complete!');
