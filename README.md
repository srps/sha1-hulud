# Shai-Hulud Scanner

A cross-platform security scanner to detect Shai-Hulud 2.0 malware in npm packages and GitHub repositories.

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

## Installation

### Pre-built Binaries

Download the latest release from the [Releases](https://github.com/srps/sha1-hulud/releases) page for your platform.

**Quick install (Linux/macOS):**

```bash
# Download latest release
VERSION="v1.0.0"  # Update with latest version
PLATFORM="linux-amd64"  # or darwin-amd64, darwin-arm64, windows-amd64.exe

wget https://github.com/srps/sha1-hulud/releases/download/${VERSION}/sha1-hulud-scanner-${PLATFORM}
chmod +x sha1-hulud-scanner-${PLATFORM}
./sha1-hulud-scanner-${PLATFORM} -download
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

### Cross-platform Build

```bash
# Linux
GOOS=linux GOARCH=amd64 go build -o sha1-hulud-scanner-linux-amd64 scan_malware.go

# macOS
GOOS=darwin GOARCH=amd64 go build -o sha1-hulud-scanner-darwin-amd64 scan_malware.go
GOOS=darwin GOARCH=arm64 go build -o sha1-hulud-scanner-darwin-arm64 scan_malware.go

# Windows
GOOS=windows GOARCH=amd64 go build -o sha1-hulud-scanner-windows-amd64.exe scan_malware.go
```

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

## CSV Format Support

The scanner supports both formats:

**Standard format:**

```csv
Package Name,Version
@zapier/platform-cli,18.0.4
posthog-node,5.13.3
```

**Wiz Research format** (auto-detected when using `-download`):

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

### 1. Compromised npm Packages

Checks installed packages against the known list of compromised package@version combinations. Uses the latest IOCs from [Wiz Research](https://github.com/wiz-sec-public/wiz-research-iocs) when using `-download` flag.

### 2. Attack Indicators

- **Payload files**: `setup_bun.js`, `bun_environment.js`, `actionsSecrets.json`
- **Exfiltration files**: `cloud.json`, `contents.json`, `environment.json`, `truffleSecrets.json`
- **Suspicious preinstall scripts**: Patterns matching Shai-Hulud execution methods

### 3. GitHub Workflows

- `discussion.yaml` - Backdoor workflow that executes on self-hosted runners
- `formatter_*.yml` - Secret exfiltration workflows

## Output

The scanner provides:

- List of compromised packages found
- Attack indicators detected
- Actionable remediation steps

Exit code `1` indicates findings, `0` indicates clean scan.

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

## Why Go?

Go is an excellent choice for this utility because:

✅ **Single Binary**: No runtime dependencies, easy distribution  
✅ **Cross-platform**: Compile once, run anywhere  
✅ **Fast**: Efficient filesystem scanning  
✅ **Low overhead**: Minimal resource usage  
✅ **Easy deployment**: Users just download and run  

### Alternative Approaches Considered

- **Node.js**: Native to npm ecosystem, but requires Node runtime
- **Python**: Cross-platform but requires Python interpreter
- **Rust**: Similar benefits to Go, but steeper learning curve
- **Shell scripts**: Simple but less portable across platforms

## Contributing

Contributions welcome! Areas for improvement:

- [ ] JSON output format option
- [ ] Download CSV automatically from Wiz IOCs
- [ ] CI/CD integration (GitHub Actions, GitLab CI)
- [ ] Docker image for containerized scanning
- [ ] Integration with package managers (npm audit, etc.)
- [ ] Windows registry scanning for npm global packages
- [ ] Bun cache scanning
- [ ] Yarn/pnpm specific checks

## License

MIT License - See LICENSE file

## References

- [Wiz Research: Shai-Hulud 2.0](https://www.wiz.io/blog/shai-hulud-2-0-ongoing-supply-chain-attack)
- [Wiz IOCs](https://www.wiz.io/blog/shai-hulud-2-0-ongoing-supply-chain-attack#appendix)
- [Aikido Blog Post](https://www.aikido.dev/blog/shai-hulud-2-0)
- [Step Security Blog Post](https://www.stepsecurity.io/blog/shai-hulud-2-0)

## Disclaimer

This tool is provided as-is for security scanning purposes. Always verify findings and follow your organization's security procedures.

Always verify the source and binaries before running. Binaries are a convenience, build from source for maximum security.
