# Task runner: short names for the commands we run often.
# Recipe lines MUST start with a TAB, not spaces.
# `make` or `make help` lists the targets.

.DEFAULT_GOAL := help
.PHONY: help install fmt lint typecheck test hooks check up down

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install: ## Install all workspace packages + dev tools, and the git hooks
	uv sync --all-packages --locked
	uv run pre-commit install

fmt: ## Auto-format and auto-fix code
	uv run ruff format .
	uv run ruff check --fix .

lint: ## Check style and lint rules (no changes made)
	uv run ruff format --check .
	uv run ruff check .

typecheck: ## Static type check (pyright, strict)
	uv run pyright

test: ## Run the test suite (integration tests need Docker)
	uv run pytest

hooks: ## Run every pre-commit hook against all files
	uv run pre-commit run --all-files --show-diff-on-failure

check: hooks typecheck test ## Everything CI runs. Run this before pushing.

up: ## Start the Docker Compose stack
	docker compose up -d --wait

down: ## Stop the stack (keeps data volumes)
	docker compose down
