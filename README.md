# Shai-Hulud Scanner

[![Go](https://github.com/srps/sha1-hulud/actions/workflows/ci.yml/badge.svg)](https://github.com/srps/sha1-hulud/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A cross-platform security scanner to detect Shai-Hulud 2.0 malware in npm packages and GitHub repositories.

## Table of Contents

- [What is Shai-Hulud 2.0?](#what-is-shai-hulud-20)
- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Usage](#usage)
- [What It Scans](#what-it-scans)
- [Example Output](#example-output)
- [CI/CD Integration](#cicd-integration)
- [Remediation Steps](#remediation-steps)
- [Contributing](#contributing)
- [License](#license)

## What is Shai-Hulud 2.0?

Shai-Hulud 2.0 is a supply-chain attack targeting npm packages. It:

- Executes malicious code during `preinstall` phase
- Exfiltrates credentials (GitHub tokens, AWS/GCP/Azure keys, npm tokens)
- Creates malicious GitHub workflows for backdoor access
- Publishes stolen secrets to public GitHub repositories

**Reference**: [Wiz Research Blog Post](https://www.wiz.io/blog/shai-hulud-2-0-ongoing-supply-chain-attack)

## Features

- ✅ **Auto-download latest IOCs** from Wiz Research GitHub repository
- ✅ **Parallel scanning** - Uses all CPU cores for 2-4x faster scans
- ✅ **Fast directory traversal** - Uses [fastwalk](https://github.com/charlievieth/fastwalk) for ~2.5x faster filesystem scanning on macOS, ~4x faster on Linux
- ✅ Scans `node_modules` directories for compromised package versions
- ✅ Detects suspicious payload files (`setup_bun.js`, `bun_environment.js`, etc.)
- ✅ Identifies malicious preinstall scripts
- ✅ Scans GitHub workflows for backdoor patterns
- ✅ Cross-platform (Windows, macOS, Linux)
- ✅ Single binary - no dependencies required
- ✅ Optimized parallel processing for maximum performance
- ✅ Supports Wiz IOCs format (handles version ranges with `||` separators)
- ✅ Scans global npm/pnpm packages (per Node.js environment)
- ✅ Scans Bun package cache

## Quick Start

### Go Version (Recommended)

**Download binary:**

```bash
# Linux/macOS
curl -L https://github.com/srps/sha1-hulud/releases/latest/download/sha1-hulud-scanner-linux-amd64 -o sha1-hulud-scanner
chmod +x sha1-hulud-scanner
./sha1-hulud-scanner -download

# Or build from source
go build -o sha1-hulud-scanner scan_malware.go
./sha1-hulud-scanner -download
```

## Installation

### Pre-built Binaries

Download the latest release from the [Releases](https://github.com/srps/sha1-hulud/releases) page for your platform.

**Quick install (Linux/macOS):**

```bash
# Using curl (recommended)
curl -L https://github.com/srps/sha1-hulud/releases/latest/download/sha1-hulud-scanner-linux-amd64 -o sha1-hulud-scanner
chmod +x sha1-hulud-scanner
./sha1-hulud-scanner -download

# Or using wget with specific version
VERSION="v1.0.0"  # Update with latest version
PLATFORM="linux-amd64"  # or darwin-amd64, darwin-arm64, windows-amd64.exe

wget https://github.com/srps/sha1-hulud/releases/download/${VERSION}/sha1-hulud-scanner-${PLATFORM}
chmod +x sha1-hulud-scanner-${PLATFORM}
./sha1-hulud-scanner-${PLATFORM} -download
```

**Windows:**

```powershell
# Download latest release
Invoke-WebRequest -Uri "https://github.com/srps/sha1-hulud/releases/latest/download/sha1-hulud-scanner-windows-amd64.exe" -OutFile "sha1-hulud-scanner.exe"
.\sha1-hulud-scanner.exe -download
```

**Verify checksums:**

```bash
wget https://github.com/srps/sha1-hulud/releases/download/${VERSION}/sha256sums.txt
sha256sum -c sha256sums.txt
```

### Build from Source

```bash
go build -o sha1-hulud-scanner scan_malware.go
```

### Node.js Version

```bash
git clone https://github.com/srps/sha1-hulud.git
cd sha1-hulud
node scan-malware.js -download
```

**Requirements:** Node.js 14+ (uses built-in modules only)

## Usage

```bash
# Download latest IOCs and scan (recommended)
./sha1-hulud-scanner -download

# Download latest IOCs and scan specific directory
./sha1-hulud-scanner -download -root /path/to/scan

# Use local CSV file
./sha1-hulud-scanner -csv sha1-hulud.csv

# Scan specific directory with local CSV
./sha1-hulud-scanner -csv sha1-hulud.csv -root /path/to/scan

# Scan entire system (requires appropriate permissions)
./sha1-hulud-scanner -download -root /
```

### Flags

- `-csv <path>`: Path to local CSV file with compromised packages
- `-download`: Download latest IOCs from [Wiz Research GitHub](https://github.com/wiz-sec-public/wiz-research-iocs)
- `-root <path>`: Directory to scan (default: user home directory)

Both Go and Node.js versions support the same flags and provide identical functionality.

## CSV Format Support

Supports both standard and Wiz Research formats:

**Standard:**

```csv
Package Name,Version
@zapier/platform-cli,18.0.4
```

**Wiz format** (auto-detected with `-download`):

```csv
Package,Version
@zapier/platform-cli,= 18.0.4 || = 18.0.3 || = 18.0.2
posthog-node,= 5.13.3
```

The scanner automatically handles:

- `=` prefix (stripped automatically)
- Multiple versions separated by `||` (all versions are checked)
- Empty versions (skipped)

## What It Scans

The scanner performs comprehensive checks across multiple locations:

### 1. Local `node_modules` Directories

Scans all `node_modules` directories found in the specified path (or home directory by default). Checks installed packages against the known list of compromised package@version combinations.

### 2. Global npm Packages

Scans globally installed npm packages across all detected Node.js environments:

- System Node.js
- nvm installations
- fnm installations
- asdf installations
- mise installations

### 3. Global pnpm Packages

Scans globally installed pnpm packages for each Node.js environment.

### 4. Bun Package Cache

Scans Bun's package cache directory (`~/.bun/install/cache` or `$BUN_INSTALL_CACHE_DIR`) for compromised packages.

### 5. Attack Indicators

Detects suspicious files and patterns:

- **Payload files**: `setup_bun.js`, `bun_environment.js`, `actionsSecrets.json`
- **Exfiltration files**: `cloud.json`, `contents.json`, `environment.json`, `truffleSecrets.json`
- **Suspicious preinstall scripts**: Patterns matching Shai-Hulud execution methods

### 6. GitHub Workflows

Scans for malicious GitHub workflow files:

- `discussion.yaml` - Backdoor workflow that executes on self-hosted runners
- `formatter_*.yml` - Secret exfiltration workflows

**Note**: Uses the latest IOCs from [Wiz Research](https://github.com/wiz-sec-public/wiz-research-iocs) when using `-download` flag.

## Output

The scanner provides:

- List of compromised packages found
- Attack indicators detected
- Actionable remediation steps

Exit code `1` indicates findings, `0` indicates clean scan.

### Using in Scripts

The scanner's exit codes make it easy to integrate into scripts and CI/CD pipelines:

```bash
#!/bin/bash
if ./sha1-hulud-scanner -download; then
    echo "✅ Scan passed - no threats detected"
else
    echo "❌ Scan failed - threats detected!"
    exit 1
fi
```

## Example Output

**Clean scan:**

```text
📥 Downloading latest Shai-Hulud IOCs from Wiz Research...
✅ Downloaded IOCs to: /tmp/shai-hulud-iocs-1234567890.csv
📋 Loaded 1089 compromised package versions
🔍 Scanning for sha1-hulud malicious packages...
Scanning under: /Users/username
Found 15 node_modules directories
Using 8 parallel workers

🔍 Scanning global packages and Bun cache...
  Detected 2 Node.js environment(s)

🔍 Scanning for malicious GitHub workflows...

============================================================
SHA1-HULUD MALWARE SCAN REPORT
============================================================

✅ No sha1-hulud compromised packages detected

💡 Stay vigilant: New compromised packages may still be discovered.
```

**Compromised packages found:**

```
============================================================
SHA1-HULUD MALWARE SCAN REPORT
============================================================

🔴 COMPROMISED PACKAGES DETECTED:

  Package: @zapier/platform-cli@18.0.4
    └─ /path/to/project/node_modules/@zapier/platform-cli
    └─ npm global (nvm@18.17.0)

⚠️  ATTACK INDICATORS FOUND:
  • Suspicious file 'setup_bun.js' found in malicious-pkg@1.0.0 at /path/to/node_modules/malicious-pkg
  • Suspicious GitHub workflow file: .github/workflows/discussion.yaml (potential backdoor)

============================================================
🚨 IMMEDIATE ACTIONS REQUIRED:
============================================================

## Remediation Steps

If malware is detected:

1. **Rotate ALL credentials immediately**:
   - GitHub tokens & SSH keys
   - npm tokens
   - AWS, GCP, Azure credentials

2. **Check GitHub repositories**:
   - Search for repos with description "Sha1-Hulud: The Second Coming"
   - Delete any unauthorized repositories
   - Review repository access logs

3. **Review GitHub Actions**:
   - Check `.github/workflows/` for suspicious files
   - Remove unauthorized self-hosted runners (especially named "SHA1HULUD")
   - Review workflow execution history

4. **Remove compromised packages**:
   - Delete `node_modules` and `package-lock.json`
   - Reinstall from clean versions
   - Update to versions published before Nov 21, 2025

## CI/CD Integration

### GitHub Actions

Add security scanning to your CI/CD pipeline:

```yaml
name: Security Scan

on:
  schedule:
    - cron: '0 0 * * *'  # Daily scan
  workflow_dispatch:

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Download and run scanner
        run: |
          curl -L https://github.com/srps/sha1-hulud/releases/latest/download/sha1-hulud-scanner-linux-amd64 -o scanner
          chmod +x scanner
          ./scanner -download -root ${{ github.workspace }}
```

### GitLab CI

```yaml
security-scan:
  image: golang:1.22
  script:
    - curl -L https://github.com/srps/sha1-hulud/releases/latest/download/sha1-hulud-scanner-linux-amd64 -o scanner
    - chmod +x scanner
    - ./scanner -download -root $CI_PROJECT_DIR
  allow_failure: false
```

## Performance

Typical scan performance on a development machine:

- **~100 node_modules directories**: 2-5 seconds
- **~1000 node_modules directories**: 10-30 seconds
- **Large enterprise scan**: 1-3 minutes

Performance scales with:

- Number of CPU cores (parallel scanning)
- Storage type (SSD vs HDD)
- Number of `node_modules` directories

## Troubleshooting

### No node_modules directories found

- Ensure you have read permissions to the directory being scanned
- Check if `node_modules` directories exist in the specified path
- Try scanning a specific project directory: `-root /path/to/project`

### Permission errors

The scanner automatically skips directories it cannot access and continues scanning. You'll see warnings but scanning will continue.

### Global packages not detected

- Ensure Node.js is installed and in your PATH
- For nvm/fnm/asdf: Ensure the version manager is properly configured
- The scanner detects multiple Node.js environments automatically

| Feature | Go Version | Node.js Version |
|---------|-----------|-----------------|
| Single binary | ✅ No dependencies | ❌ Requires Node.js |
| Build required | ✅ Compile once | ❌ Run directly |
| Performance | ✅ Fast (fastwalk) | ✅ Fast (parallel) |
| Distribution | ✅ Easy (single file) | ✅ Easy (clone & run) |

**Choose Go version for:** Production deployments, CI/CD pipelines, users without Node.js  
**Choose Node.js version for:** Development environments, quick testing, Node.js projects

## Remediation Steps

If malware is detected:

1. **Rotate ALL credentials** - GitHub tokens, SSH keys, npm tokens, AWS/GCP/Azure credentials
2. **Check GitHub repositories** - Search for repos with "Sha1-Hulud: The Second Coming", delete unauthorized repos
3. **Review GitHub Actions** - Check `.github/workflows/` for suspicious files, remove unauthorized runners
4. **Remove compromised packages** - Delete `node_modules`, reinstall from clean versions published before Nov 21, 2025
5. **Clear package caches** - `npm cache clean --force`, `pnpm store prune`, `rm -rf ~/.bun/install/cache`

## Troubleshooting

- **No node_modules found**: Check read permissions, try scanning a specific directory
- **Permission errors**: Scanner automatically skips inaccessible directories and continues
- **Global packages not detected**: Ensure Node.js is in PATH, version managers properly configured
- **Download fails**: Check internet connection, use `-csv` flag with local file as fallback

## Contributing

Contributions welcome! Areas for improvement:

- [ ] JSON output format option
- [ ] Docker image for containerized scanning
- [ ] **Package Manager Integration** (see [PACKAGE_MANAGER_INTEGRATION.md](PACKAGE_MANAGER_INTEGRATION.md)):
  - [ ] Lock file analysis (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`)
  - [ ] Transitive dependency checking
  - [ ] Version range resolution (^, ~, etc.)
  - [ ] Yarn support (lock files, workspaces)
  - [ ] npm audit integration
  - [ ] Fix suggestions (automatic remediation)
- [ ] Windows registry scanning for npm global packages
- [ ] Progress indicators for long scans
- [ ] Caching scan results

**Already implemented:**

- ✅ CI/CD integration (GitHub Actions)
- ✅ Bun cache scanning
- ✅ Global npm/pnpm package scanning
- ✅ Node.js version with full feature parity
- ✅ `package.json` analysis (check declared dependencies)

## License

MIT License - See LICENSE file

## References

- [Wiz Research: Shai-Hulud 2.0](https://www.wiz.io/blog/shai-hulud-2-0-ongoing-supply-chain-attack)
- [Wiz IOCs](https://www.wiz.io/blog/shai-hulud-2-0-ongoing-supply-chain-attack#appendix)
- [Aikido Blog Post](https://www.aikido.dev/blog/shai-hulud-2-0)
- [Step Security Blog Post](https://www.stepsecurity.io/blog/shai-hulud-2-0)

## Disclaimer

This tool is provided as-is for security scanning purposes. Always verify findings and follow your organization's security procedures. Build from source for maximum security.
