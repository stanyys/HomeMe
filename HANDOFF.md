# Handoff: status as of 2026-11-13

This project was started in a Claude Code session in the wrong folder (`~/repos/iss-agent-3/assignment-3`, which sits inside the `iss-agent-3` git repo). This file carries the session's state to the new location. Durable context is in `CLAUDE.md`. Delete this file once Feature 1 is underway.

## Status
- No code written yet. Existing files: `pyproject.toml` (uv init stub), empty `README.md`, `src/assignment_3/__init__.py` stub, `data/hdb_resale_prices.csv`.
- **Git not yet initialised.** Approved: a **separate repo** for this project (not the parent `iss-agent-3` repo). Do this first in the new location, after confirming with the user.
- The **Feature 1 plan below is approved**, including all the defaults in "Confirmed for Feature 1". Still wait for the user's explicit go-ahead before running or creating anything.

## Feature 1 (approved plan): load the CSV and set up the vector DB
Branch: `feature/data-foundation`. One commit per step (Conventional Commits).

**Step 0: Scaffold** (delete the `src/assignment_3` stub, approved)
```
pyproject.toml          # uv workspace root + dev tools (ruff, pyright, pytest, pre-commit)
compose.yaml
.env.example
Makefile
docs/adr/
data/hdb_resale_prices.csv
packages/contracts/     # shared Pydantic models
services/db-migrations/ # Alembic: schema + roles
services/resale-loader/ # one-shot: CSV -> Postgres
services/vector-init/   # one-shot: create Qdrant collection
```

**Step 1: ADRs 0001–0008**
1. Recording decisions as ADRs
2. Each agent as its own service (option B)
3. LangGraph
4. FastAPI + Pydantic between services
5. Postgres for SQL data + Qdrant for vectors
6. Compose before Kubernetes
7. DeepEval for evals + LangSmith for tracing
8. Raw table + clean view

**Step 2: Postgres schema with Alembic (tests first, testcontainers)**
- Creates `resale_raw` (all columns as text) and the typed view `resale_transactions`.
- Parsing:
  - `2017-01` -> DATE
  - `10 TO 12` -> `storey_min = 10`, `storey_max = 12`
  - `61 years 04 months` -> `remaining_lease_months = 736`
  - Edge cases: "61 years" with no months; "1 month" (singular)
- Roles:
  - `migrator` owns the schema
  - `loader` can write `resale_raw` only
  - `sql_agent_ro` can SELECT on the view only (no raw table, no DML/DDL)
- Migrations can be applied and rolled back.

**Step 3: Resale loader (tests first)**
- Header contract: fail loudly if the CSV columns change.
- Idempotent: TRUNCATE + COPY in one transaction; on failure the old data stays.
- Loaded row count must equal the CSV row count.
- psycopg 3 `COPY`.

**Step 4: Qdrant setup (tests first, fake embedder, no OpenAI calls in tests)**
- Collection holds both:
  - named dense vectors: 1536-d, cosine
  - named sparse BM25 vectors (hybrid-ready, no re-index needed later)
- Payload: `source_url`, `title`, `section`, `scraped_at`, `chunk_index`, with indexes on the filter fields.
- `PolicyDocument` contract plus an ingest function using deterministic point IDs (upserts, no duplicates).
- **On hold:** the `PolicyDocument` fields depend on the user's scraper output format. Ask before finalising. Chunking is deferred.

**Step 5: Docker Compose, hardened**
- `postgres` healthy -> `db-migrations` -> `resale-loader`, with `vector-init` running alongside.
- Every container: pinned image digest, non-root user, `no-new-privileges`, `cap_drop: ALL`, read-only rootfs, healthcheck, resource limits.
- CSV mounted read-only.
- Qdrant API key on; Postgres `scram-sha-256`.
- Internal network; dev ports published on 127.0.0.1 only.
- Secrets from Docker secrets or a git-ignored `.env`.
- `make scan` runs Trivy over all images.

No LLM in this feature, so no evals yet. EDD starts with the first agent.

## Confirmed for Feature 1
- Git: separate repo for this project.
- testcontainers for integration tests (Docker must be running for the tests).
- Tooling: ruff, pyright, pytest, pre-commit, Makefile.
- Delete the `src/assignment_3` stub.
- One commit per step, Conventional Commits, on `feature/data-foundation`.
- Scraper: on hold. The user will come back to it.
