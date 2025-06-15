.PHONY: all help setup verify clean test install-% verify-% list

# Default target
all: setup

# Show help
help:
	@echo "Dotfiles Management"
	@echo "=================="
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Main targets:"
	@echo "  setup          - Setup all default tools"
	@echo "  verify         - Verify all installations"
	@echo "  clean          - Remove all symlinks and restore backups"
	@echo "  test           - Run setup in dry-run mode"
	@echo "  list           - List available tools"
	@echo ""
	@echo "Tool-specific targets:"
	@echo "  install-TOOL   - Setup specific tool (e.g., make install-git)"
	@echo "  verify-TOOL    - Verify specific tool (e.g., make verify-git)"
	@echo ""
	@echo "Examples:"
	@echo "  make                    # Setup all default tools"
	@echo "  make install-nvim       # Setup only Neovim"
	@echo "  make verify             # Verify all installations"
	@echo "  make test               # Dry run to see what would happen"

# Setup all default tools
setup:
	@./setup.sh

# Verify all installations
verify:
	@echo "Verifying all tool installations..."
	@for tool in zsh git nvim kitty karabiner iterm; do \
		if [ -f "./$$tool/setup.sh" ]; then \
			echo ""; \
			./$$tool/setup.sh verify || true; \
		fi \
	done

# Clean up all installations
clean:
	@echo "WARNING: This will remove all dotfile symlinks!"
	@echo "Backups will be restored if available."
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "Cleaning up dotfiles..."; \
		./scripts/cleanup.sh; \
	else \
		echo "Cleanup cancelled."; \
	fi

# Test setup in dry-run mode
test:
	@./setup.sh --dry-run

# List available tools
list:
	@echo "Available tools:"
	@for dir in */; do \
		if [ -f "$$dir/setup.sh" ] && [[ ! "$$dir" =~ ^(lib|bash|vim|vscode|themes)/ ]]; then \
			echo "  - $${dir%/}"; \
		fi \
	done

# Install specific tool
install-%:
	@tool=$*; \
	if [ -f "./$$tool/setup.sh" ]; then \
		./setup.sh $$tool; \
	else \
		echo "Error: Tool '$$tool' not found"; \
		echo "Run 'make list' to see available tools"; \
		exit 1; \
	fi

# Verify specific tool
verify-%:
	@tool=$*; \
	if [ -f "./$$tool/setup.sh" ]; then \
		./$$tool/setup.sh verify; \
	else \
		echo "Error: Tool '$$tool' not found"; \
		echo "Run 'make list' to see available tools"; \
		exit 1; \
	fi

# Development targets
.PHONY: lint check

# Check shell scripts for errors
lint:
	@echo "Linting shell scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		find . -name "*.sh" -type f | xargs shellcheck || true; \
	else \
		echo "shellcheck not found. Install with: brew install shellcheck"; \
	fi

# Run all checks
check: lint verify
	@echo "All checks completed!"