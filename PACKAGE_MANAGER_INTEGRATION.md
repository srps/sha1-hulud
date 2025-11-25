# Package Manager Integration - What's Missing

## Current Implementation

Our scanner currently:
- ✅ Scans installed packages in `node_modules` directories
- ✅ Checks global npm/pnpm packages
- ✅ Scans Bun cache
- ✅ Detects suspicious files and scripts
- ✅ Uses static IOC list (CSV from Wiz Research)

## What's Missing vs Full Package Manager Integration

### 1. Lock File Analysis ❌

**Missing:**
- `package-lock.json` analysis
- `yarn.lock` analysis  
- `pnpm-lock.yaml` analysis

**Why it matters:**
- Lock files show what **should** be installed vs what **is** installed
- Can detect discrepancies (lock file says v1.0.0 but v1.0.1 is installed)
- Shows transitive dependencies explicitly
- Provides integrity hashes

**What to add:**
```go
// Scan lock files to detect:
// 1. Packages declared but not matching installed versions
// 2. Transitive dependencies that might be compromised
// 3. Integrity mismatches
```

### 2. package.json Analysis ❌

**Missing:**
- Reading `package.json` files directly (not just installed packages)
- Checking declared dependencies against IOCs
- Version range resolution (^1.0.0, ~1.0.0, etc.)

**Why it matters:**
- Can detect threats before `npm install` runs
- Identifies vulnerable version ranges
- Works even if `node_modules` doesn't exist

**What to add:**
```go
// Find and parse all package.json files
// Check dependencies/devDependencies against IOCs
// Resolve version ranges to check if they include compromised versions
```

### 3. Transitive Dependency Checking ❌

**Missing:**
- Recursive dependency tree analysis
- Checking dependencies of dependencies
- Deep scanning beyond direct dependencies

**Why it matters:**
- Shai-Hulud might be in a transitive dependency
- Example: `my-app` → `dep-a` → `compromised-pkg@bad-version`

**What to add:**
```go
// Build dependency tree from lock files
// Recursively check all transitive dependencies
// Report compromised packages at any depth
```

### 4. npm audit Integration ❌

**Missing:**
- Integration with npm's vulnerability database
- Real-time vulnerability checking
- Severity ratings (low, moderate, high, critical)
- CVE information

**Why it matters:**
- npm audit has broader vulnerability coverage
- Provides severity information
- Can suggest fixes automatically

**What to add:**
```go
// Option 1: Call npm audit programmatically
// Option 2: Query npm advisory API directly
// Option 3: Download npm advisory database
```

### 5. Version Range Resolution ❌

**Missing:**
- Understanding semver ranges (^, ~, >=, etc.)
- Checking if ranges include compromised versions
- Resolving ranges to actual installable versions

**Why it matters:**
- `package.json` might say `^18.0.0` which includes `18.0.4` (compromised)
- Need to check if the range overlaps with compromised versions

**What to add:**
```go
// Parse semver ranges
// Check if compromised versions fall within declared ranges
// Example: "^18.0.0" includes "18.0.4" (compromised)
```

### 6. Yarn Support ❌

**Missing:**
- `yarn.lock` parsing
- Yarn global package checking
- Yarn workspace detection

**Why it matters:**
- Many projects use Yarn instead of npm
- Yarn has different lock file format
- Yarn workspaces need special handling

**What to add:**
```go
// Parse yarn.lock (YAML format)
// Check yarn global packages
// Detect and handle yarn workspaces
```

### 7. Fix Suggestions ❌

**Missing:**
- Automatic fix recommendations
- Update suggestions (e.g., "update to 18.0.5")
- Patch suggestions

**Why it matters:**
- Users need actionable remediation
- Can automate fixes in CI/CD

**What to add:**
```go
// For each compromised package:
// 1. Find safe versions (not in IOC list)
// 2. Suggest updates
// 3. Provide npm/yarn commands to fix
```

### 8. Workspace/Monorepo Support ❌

**Missing:**
- Detecting npm/yarn/pnpm workspaces
- Scanning all workspace packages
- Handling workspace dependencies

**Why it matters:**
- Many projects use monorepos
- Each workspace needs separate scanning
- Workspace dependencies need special handling

**What to add:**
```go
// Detect workspace configuration
// Scan each workspace independently
// Handle workspace: protocol dependencies
```

### 9. Real-time Vulnerability Database ❌

**Missing:**
- Live vulnerability checking
- Integration with npm advisory API
- CVE database integration

**Why it matters:**
- Static CSV becomes outdated
- New vulnerabilities discovered daily
- Need real-time threat intelligence

**What to add:**
```go
// Query npm advisory API: https://github.com/advisories
// Or use: https://registry.npmjs.org/-/npm/v1/security/advisories
// Cache results for performance
```

### 10. Package Integrity Verification ❌

**Missing:**
- Hash verification from lock files
- Package integrity checks
- Detecting tampered packages

**Why it matters:**
- Lock files contain integrity hashes
- Can detect if packages were modified
- Prevents supply chain tampering

**What to add:**
```go
// Extract integrity hashes from lock files
// Verify package tarballs match expected hashes
// Report integrity mismatches
```

## Implementation Priority

### High Priority (Most Impact)

1. **package.json Analysis** - Detect threats before installation
2. **Lock File Analysis** - Find transitive dependencies
3. **Version Range Resolution** - Check if ranges include compromised versions

### Medium Priority

4. **Yarn Support** - Cover more projects
5. **Fix Suggestions** - Better remediation
6. **Workspace Support** - Handle monorepos

### Low Priority (Nice to Have)

7. **npm audit Integration** - Broader vulnerability coverage
8. **Real-time Database** - Live threat intelligence
9. **Integrity Verification** - Detect tampering

## Example: What Full Integration Would Look Like

```bash
# Current behavior
./sha1-hulud-scanner -download
# Only checks installed packages in node_modules

# With full integration
./sha1-hulud-scanner -download -check-lockfiles -check-package-json
# Checks:
# - Installed packages (current)
# - package.json dependencies (new)
# - Lock files for transitive deps (new)
# - Version ranges (new)
# - Yarn workspaces (new)
```

## Comparison Table

| Feature | Current | Full Integration |
|---------|---------|------------------|
| Installed packages | ✅ | ✅ |
| Global packages | ✅ | ✅ |
| Bun cache | ✅ | ✅ |
| package.json | ❌ | ✅ |
| Lock files | ❌ | ✅ |
| Transitive deps | ❌ | ✅ |
| Version ranges | ❌ | ✅ |
| Yarn support | ❌ | ✅ |
| npm audit | ❌ | ✅ |
| Fix suggestions | ❌ | ✅ |
| Workspaces | ❌ | ✅ |

