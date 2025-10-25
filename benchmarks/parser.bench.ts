/**
 * Parser-specific benchmarks
 * Tests the performance of class parsing operations
 */

import { bench, group, run } from 'mitata';
import { execSync } from 'child_process';

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

group('Parser - Simple Classes', () => {
  bench('Parse simple utilities', () => {
    execSync(`echo "${testCases.simple}" | ../zig-out/bin/headwind parse`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Parser - Variants', () => {
  bench('Parse single variants', () => {
    execSync(`echo "${testCases.withVariants}" | ../zig-out/bin/headwind parse`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });

  bench('Parse multiple variants', () => {
    execSync(`echo "${testCases.multipleVariants}" | ../zig-out/bin/headwind parse`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });

  bench('Parse complex variants', () => {
    execSync(`echo "${testCases.complex}" | ../zig-out/bin/headwind parse`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Parser - Arbitrary Values', () => {
  bench('Parse arbitrary values', () => {
    execSync(`echo "${testCases.arbitraryValues}" | ../zig-out/bin/headwind parse`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Parser - Special Cases', () => {
  bench('Parse important modifier', () => {
    execSync(`echo "${testCases.important}" | ../zig-out/bin/headwind parse`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });

  bench('Parse negative values', () => {
    execSync(`echo "${testCases.negative}" | ../zig-out/bin/headwind parse`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Parser - Scale Testing', () => {
  bench('Parse 100 classes', () => {
    execSync(`echo "${testCases.long}" | ../zig-out/bin/headwind parse`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });

  bench('Parse 1000 classes', () => {
    execSync(`echo "${testCases.veryLong}" | ../zig-out/bin/headwind parse`, {
      encoding: 'utf-8',
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
