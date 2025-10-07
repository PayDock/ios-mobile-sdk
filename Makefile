# Mobile SDK iOS - Development Setup
# This Makefile provides convenient commands for setting up the development environment

.PHONY: help validate-branch ensure-validation status clean-hooks setup

# Default target
help:
	@echo "Mobile SDK iOS - Branch Validation"
	@echo ""
	@echo "Available commands:"
	@echo "  make setup            - Quick setup (ensure validation is working)"
	@echo "  make validate-branch  - Validate current branch name"
	@echo "  make ensure-validation - Ensure validation is active (auto-setup if needed)"
	@echo "  make status           - Show detailed validation status"
	@echo "  make clean-hooks      - Remove all Git hooks"
	@echo "  make help             - Show this help message"
	@echo ""
	@echo "Branch naming conventions:"
	@echo "  bug/SDK-####-*, task/SDK-####-*, feature/SDK-####-*, spike/SDK-####-*, release/*"
	@echo ""
	@echo "Note: Branch validation is automatically enforced on commit/push."
	@echo "      No manual setup required - hooks are installed automatically."

# Ensure validation is active (auto-setup if needed)
ensure-validation:
	@./scripts/ensure-validation.sh

# Validate current branch name
validate-branch:
	@./scripts/validate-branch-name.sh

# Show detailed validation status
status:
	@./scripts/ensure-validation.sh --status

# Clean up all Git hooks
clean-hooks:
	@echo "Removing Git hooks..."
	@rm -f .git/hooks/pre-push
	@rm -f .git/hooks/pre-commit
	@rm -f .git/hooks/post-checkout
	@rm -f .git/hooks/.hooks-setup-complete
	@echo "Git hooks removed successfully"

# Quick setup - just ensure validation is working
setup: ensure-validation
	@echo ""
	@echo "Branch validation is now active!"
	@echo "Hooks will be automatically installed on first commit/push."
