/**
 * Parser-specific benchmarks
 * Tests the performance of class parsing operations
 */

import { bench, group, run } from 'mitata';
import { execSync } from 'child_process';
import { writeFileSync, mkdirSync, rmSync } from 'fs';

// Create temp directory
mkdirSync('temp', { recursive: true });

// Test data for different parsing scenarios
const testCases = {
  simple: 'bg-blue-500 text-white p-4',
  withVariants: 'hover:bg-blue-600 focus:ring-2 md:text-lg',
  multipleVariants: 'md:hover:focus:active:bg-red-500 lg:dark:text-white',
  arbitraryValues: 'w-[100px] h-[calc(100vh-64px)] bg-[#1da1f2]',
  complex: 'group-hover:bg-blue-500 peer-checked:text-red-500 [&:nth-child(3)]:bg-green-500',
  important: 'bg-blue-500! text-white! p-4!',
  negative: '-m-4 -translate-x-1/2 -rotate-45',
  long: Array(100).fill('bg-blue-500 text-white p-4 m-2 rounded-lg').join(' '),
  veryLong: Array(1000).fill('hover:bg-blue-600 focus:ring-2 active:scale-95').join(' '),
};

function createTestHTML(classes: string): string {
  return `<!DOCTYPE html><html><body><div class="${classes}"></div></body></html>`;
}

group('Parser - Simple Classes', () => {
  bench('Parse simple utilities', () => {
    writeFileSync('temp/simple.html', createTestHTML(testCases.simple));
    execSync('../zig-out/bin/headwind build temp/simple.html -o temp/simple.css', {
      stdio: 'pipe',
    });
  });
});

group('Parser - Variants', () => {
  bench('Parse single variants', () => {
    writeFileSync('temp/variants.html', createTestHTML(testCases.withVariants));
    execSync('../zig-out/bin/headwind build temp/variants.html -o temp/variants.css', {
      stdio: 'pipe',
    });
  });

  bench('Parse multiple variants', () => {
    writeFileSync('temp/multi-variants.html', createTestHTML(testCases.multipleVariants));
    execSync('../zig-out/bin/headwind build temp/multi-variants.html -o temp/multi-variants.css', {
      stdio: 'pipe',
    });
  });

  bench('Parse complex variants', () => {
    writeFileSync('temp/complex.html', createTestHTML(testCases.complex));
    execSync('../zig-out/bin/headwind build temp/complex.html -o temp/complex.css', {
      stdio: 'pipe',
    });
  });
});

group('Parser - Arbitrary Values', () => {
  bench('Parse arbitrary values', () => {
    writeFileSync('temp/arbitrary.html', createTestHTML(testCases.arbitraryValues));
    execSync('../zig-out/bin/headwind build temp/arbitrary.html -o temp/arbitrary.css', {
      stdio: 'pipe',
    });
  });
});

group('Parser - Special Cases', () => {
  bench('Parse important modifier', () => {
    writeFileSync('temp/important.html', createTestHTML(testCases.important));
    execSync('../zig-out/bin/headwind build temp/important.html -o temp/important.css', {
      stdio: 'pipe',
    });
  });

  bench('Parse negative values', () => {
    writeFileSync('temp/negative.html', createTestHTML(testCases.negative));
    execSync('../zig-out/bin/headwind build temp/negative.html -o temp/negative.css', {
      stdio: 'pipe',
    });
  });
});

group('Parser - Scale Testing', () => {
  bench('Parse 100 classes', () => {
    writeFileSync('temp/long.html', createTestHTML(testCases.long));
    execSync('../zig-out/bin/headwind build temp/long.html -o temp/long.css', {
      stdio: 'pipe',
    });
  });

  bench('Parse 1000 classes', () => {
    writeFileSync('temp/very-long.html', createTestHTML(testCases.veryLong));
    execSync('../zig-out/bin/headwind build temp/very-long.html -o temp/very-long.css', {
      stdio: 'pipe',
    });
  });
});

console.log('⚡ Running parser-specific benchmarks...\n');
await run({
  units: false,
  silent: false,
  avg: true,
  json: false,
  colors: true,
  min_max: true,
  percentiles: true,
});

console.log('\n✅ Parser benchmarks complete!');

// Cleanup
rmSync('temp', { recursive: true, force: true });
