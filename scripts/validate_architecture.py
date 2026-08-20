#!/usr/bin/env python3
"""
Clean Architecture Validator for Flutter Projects
Inspects Dart source files in `lib/` and verifies Clean Architecture layer invariants.
"""

import sys
import os

total_violations = 0
violation_log = []

def check_file(file_path, content):
    global total_violations
    normalized_path = file_path.replace("\\", "/")
    lines = content.splitlines()

    # Rule 1: Domain Purity Checks
    if "/domain/" in normalized_path:
        for idx, line in enumerate(lines, 1):
            trimmed = line.strip()
            if trimmed.startswith("import ") or trimmed.startswith("export "):
                if "package:flutter/" in trimmed and "package:flutter/foundation.dart" not in trimmed:
                    record_violation(file_path, idx, "CRITICAL", "INVARIANT-01: Domain layer must not import Flutter UI framework.", trimmed)
                if "package:dio/" in trimmed or "package:http/" in trimmed:
                    record_violation(file_path, idx, "CRITICAL", "INVARIANT-01: Domain layer must not import HTTP/network packages.", trimmed)
                if "/data/" in trimmed or "/presentation/" in trimmed:
                    record_violation(file_path, idx, "CRITICAL", "INVARIANT-01: Domain layer must not depend on Data or Presentation layers.", trimmed)

        if "/domain/entities/" in normalized_path:
            for idx, line in enumerate(lines, 1):
                trimmed = line.strip()
                if "fromJson(" in trimmed or "toJson(" in trimmed or "jsonDecode(" in trimmed:
                    record_violation(file_path, idx, "HIGH", "INVARIANT-03: Domain Entities must not contain JSON serialization logic.", trimmed)

    # Rule 2: Presentation Inversion Checks
    if "/presentation/" in normalized_path:
        for idx, line in enumerate(lines, 1):
            trimmed = line.strip()
            if trimmed.startswith("import "):
                if "_repository_impl.dart" in trimmed or "_data_source.dart" in trimmed or "/data/datasources/" in trimmed or "/data/repositories/" in trimmed:
                    record_violation(file_path, idx, "CRITICAL", "INVARIANT-04: Presentation layer must not import Data layer concrete implementations.", trimmed)
                if "package:dio/" in trimmed:
                    record_violation(file_path, idx, "HIGH", "Presentation layer must not directly import network packages (Dio).", trimmed)

    # Rule 3: Core Isolation
    if "/core/" in normalized_path and "/core/app/routes.dart" not in normalized_path and "/core/app/injection_container.dart" not in normalized_path:
        for idx, line in enumerate(lines, 1):
            trimmed = line.strip()
            if trimmed.startswith("import ") and "/features/" in trimmed:
                record_violation(file_path, idx, "MEDIUM", "Core components must not import feature-specific code.", trimmed)

def record_violation(file_path, line_num, severity, message, snippet):
    global total_violations
    total_violations += 1
    violation_log.append({
        "file": file_path,
        "line": line_num,
        "severity": severity,
        "message": message,
        "snippet": snippet
    })

def scan_directory(dir_path):
    if not os.path.exists(dir_path):
        print(f"Directory not found: {dir_path}")
        return

    for root, _, files in os.walk(dir_path):
        for file in files:
            if file.endswith(".dart"):
                full_path = os.path.join(root, file)
                try:
                    with open(full_path, "r", encoding="utf-8") as f:
                        content = f.read()
                        check_file(full_path, content)
                except Exception as e:
                    print(f"Error reading {full_path}: {e}")

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.getcwd(), "lib")
    print(f"\n🔍 Scanning for Clean Architecture violations in: {target}")
    scan_directory(target)

    if total_violations == 0:
        print("\n✅ ARCHITECTURE PASS: Zero Clean Architecture violations detected!\n")
        sys.exit(0)
    else:
        print(f"\n❌ ARCHITECTURE AUDIT FAILED: {total_violations} violation(s) detected:\n")
        for i, v in enumerate(violation_log, 1):
            print(f"[{v['severity']}] #{i} at {v['file']}:{v['line']}")
            print(f"    Rule: {v['message']}")
            print(f"    Code: {v['snippet']}\n")
        sys.exit(1)
