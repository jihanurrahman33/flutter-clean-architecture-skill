# Security Policy

## 1. Supported Versions

| Version | Supported          |
| :--- | :--- |
| 1.0.x   | :white_check_mark: |

---

## 2. Agent Safety & Privacy Guarantees

This agent skill is strictly local, transparent, and privacy-preserving:

- **No Remote Telemetry**: The skill scripts and instructions collect zero telemetry or usage metrics.
- **No Secret Inspection**: The skill does NOT inspect, read, or upload `.env` files, SSH keys, certificates, or keystores.
- **Local Deterministic Execution**: Validation scripts run purely offline against local Dart files in your workspace.
- **No Arbitrary Code Execution**: The skill does NOT download or execute unverified third-party binaries.

---

## 3. Reporting a Vulnerability

If you discover any security vulnerability or malicious pattern in this skill, please email the maintainers directly or open a private GitHub security advisory. We respond to all reports within 48 hours.
