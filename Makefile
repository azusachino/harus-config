.DEFAULT_GOAL := help

.PHONY: help check fmt fmt-check

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

check: ## Validate flake + build the example home generation (matches CI)
	nix flake check -L

fmt: ## Format all .nix files with alejandra
	nix fmt -- .

fmt-check: ## Verify formatting without writing (matches CI)
	nix fmt -- --check .
