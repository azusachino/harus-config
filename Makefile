.DEFAULT_GOAL := help

.PHONY: help check fmt

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

check: ## Validate flake + formatting (no build)
	nix flake check --no-build

fmt: ## Format all .nix files with alejandra
	nix fmt
