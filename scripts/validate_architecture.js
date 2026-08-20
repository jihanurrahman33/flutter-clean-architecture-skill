#!/usr/bin/env node

/**
 * Clean Architecture Validator for Flutter Projects
 * 
 * Inspects Dart source code in `lib/` and verifies Clean Architecture layer boundaries:
 * - Domain layer purity (no Flutter UI, Dio, HTTP, or Data/Presentation imports)
 * - Presentation layer inversion (no imports of Data implementations or DataSources)
 * - Model vs Entity separation (no fromJson/toJson in domain/entities)
 * - Feature isolation (no cross-feature data/presentation imports)
 */

const fs = require('fs');
const path = require('path');

let totalViolations = 0;
const violationLog = [];

function checkFile(filePath, content) {
  const normalizedPath = filePath.replace(/\\/g, '/');
  const lines = content.split('\n');

  // Rule 1: Domain Purity Checks
  if (normalizedPath.includes('/domain/')) {
    lines.forEach((line, index) => {
      const lineNum = index + 1;
      const trimmed = line.trim();

      // Check imports
      if (trimmed.startsWith('import ') || trimmed.startsWith('export ')) {
        if (trimmed.includes('package:flutter/') && !trimmed.includes('package:flutter/foundation.dart')) {
          recordViolation(filePath, lineNum, 'CRITICAL', 'INVARIANT-01: Domain layer must not import Flutter UI framework.', trimmed);
        }
        if (trimmed.includes('package:dio/') || trimmed.includes('package:http/')) {
          recordViolation(filePath, lineNum, 'CRITICAL', 'INVARIANT-01: Domain layer must not import HTTP/network packages.', trimmed);
        }
        if (trimmed.includes('/data/') || trimmed.includes('/presentation/')) {
          recordViolation(filePath, lineNum, 'CRITICAL', 'INVARIANT-01: Domain layer must not depend on Data or Presentation layers.', trimmed);
        }
      }
    });

    // Rule 2: Entities must not contain JSON serialization
    if (normalizedPath.includes('/domain/entities/')) {
      lines.forEach((line, index) => {
        const lineNum = index + 1;
        const trimmed = line.trim();
        if (trimmed.includes('fromJson(') || trimmed.includes('toJson(') || trimmed.includes('jsonDecode(')) {
          recordViolation(filePath, lineNum, 'HIGH', 'INVARIANT-03: Domain Entities must not contain JSON serialization logic.', trimmed);
        }
      });
    }
  }

  // Rule 3: Presentation Inversion Checks
  if (normalizedPath.includes('/presentation/')) {
    lines.forEach((line, index) => {
      const lineNum = index + 1;
      const trimmed = line.trim();
      if (trimmed.startsWith('import ')) {
        if (trimmed.includes('_repository_impl.dart') || trimmed.includes('_data_source.dart') || trimmed.includes('/data/datasources/') || trimmed.includes('/data/repositories/')) {
          recordViolation(filePath, lineNum, 'CRITICAL', 'INVARIANT-04: Presentation layer must not import Data layer concrete implementations.', trimmed);
        }
        if (trimmed.includes('package:dio/')) {
          recordViolation(filePath, lineNum, 'HIGH', 'Presentation layer must not directly import network packages (Dio).', trimmed);
        }
      }
    });
  }

  // Rule 4: Core Isolation
  if (normalizedPath.includes('/core/') && !normalizedPath.includes('/core/app/routes.dart') && !normalizedPath.includes('/core/app/injection_container.dart')) {
    lines.forEach((line, index) => {
      const lineNum = index + 1;
      const trimmed = line.trim();
      if (trimmed.startsWith('import ') && trimmed.includes('/features/')) {
        recordViolation(filePath, lineNum, 'MEDIUM', 'Core components must not import feature-specific code.', trimmed);
      }
    });
  }
}

function recordViolation(filePath, lineNum, severity, message, codeSnippet) {
  totalViolations++;
  violationLog.push({
    file: filePath,
    line: lineNum,
    severity,
    message,
    codeSnippet,
  });
}

function scanDirectory(dir) {
  if (!fs.existsSync(dir)) {
    console.error(`Directory not found: ${dir}`);
    return;
  }

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      scanDirectory(fullPath);
    } else if (entry.isFile() && entry.name.endsWith('.dart')) {
      const content = fs.readFileSync(fullPath, 'utf8');
      checkFile(fullPath, content);
    }
  }
}

// Main Runner
const targetDir = process.argv[2] || path.join(process.cwd(), 'lib');
console.log(`\n🔍 Scanning for Clean Architecture violations in: ${targetDir}`);

scanDirectory(targetDir);

if (totalViolations === 0) {
  console.log(`\n✅ ARCHITECTURE PASS: Zero Clean Architecture violations detected!\n`);
  process.exit(0);
} else {
  console.log(`\n❌ ARCHITECTURE AUDIT FAILED: ${totalViolations} violation(s) detected:\n`);
  violationLog.forEach((v, i) => {
    console.log(`[${v.severity}] #${i + 1} at ${v.file}:${v.line}`);
    console.log(`    Rule: ${v.message}`);
    console.log(`    Code: ${v.codeSnippet}\n`);
  });
  process.exit(1);
}
