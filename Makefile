.PHONY: build build-all clean test install

# Binary name
BINARY_NAME=sha1-hulud-scanner

# Build for current platform
build:
	go build -o $(BINARY_NAME) scan_malware.go

# Build for all platforms
build-all:
	@echo "Building for Linux AMD64..."
	@GOOS=linux GOARCH=amd64 go build -o $(BINARY_NAME)-linux-amd64 scan_malware.go
	@echo "Building for Linux ARM64..."
	@GOOS=linux GOARCH=arm64 go build -o $(BINARY_NAME)-linux-arm64 scan_malware.go
	@echo "Building for macOS AMD64..."
	@GOOS=darwin GOARCH=amd64 go build -o $(BINARY_NAME)-darwin-amd64 scan_malware.go
	@echo "Building for macOS ARM64..."
	@GOOS=darwin GOARCH=arm64 go build -o $(BINARY_NAME)-darwin-arm64 scan_malware.go
	@echo "Building for Windows AMD64..."
	@GOOS=windows GOARCH=amd64 go build -o $(BINARY_NAME)-windows-amd64.exe scan_malware.go
	@echo "Building for Windows ARM64..."
	@GOOS=windows GOARCH=arm64 go build -o $(BINARY_NAME)-windows-arm64.exe scan_malware.go
	@echo "Done! Binaries created in current directory."

# Clean build artifacts
clean:
	rm -f $(BINARY_NAME) $(BINARY_NAME)-*

# Run tests (if you add tests)
test:
	go test -v ./...

# Install to GOPATH/bin
install: build
	go install

# Run with default CSV
run: build
	./$(BINARY_NAME) -csv sha1-hulud.csv

# Format code
fmt:
	go fmt ./...

# Lint code
lint:
	golangci-lint run || echo "Install golangci-lint for linting: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"

# Create a release tag (usage: make release VERSION=v1.0.0)
release:
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required. Usage: make release VERSION=v1.0.0"; \
		exit 1; \
	fi
	@echo "Creating release tag $(VERSION)..."
	@git tag -a $(VERSION) -m "Release $(VERSION)"
	@echo "Tag created. Push with: git push origin $(VERSION)"
	@echo "Or push all tags: git push --tags"

