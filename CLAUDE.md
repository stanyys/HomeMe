# HDB Q&A Multi-Agent App

## Working rules (from the user — always follow)
- **Ask before deciding.** Always prompt the user for specifics, especially design decisions and code frameworks. Present options with a recommendation; the user chooses.
- **Never run anything without an explicit go-ahead.** No commands, edits, or builds until the user says so. Exception: saving to Claude memory is allowed.
- **Teach as you go.** The user is a newly minted Senior AI Engineer (ex-Senior Data Scientist). Strong on DS/ML; wants the reasoning and trade-offs behind SWE, design, and architecture recommendations. Don't over-explain DS/ML basics.
- **TDD and EDD, always.** Tests first for deterministic code (LLM faked); eval suites with thresholds (DeepEval) for LLM behaviour.

## What we're building
An HDB (Singapore Housing & Development Board) Q&A multi-agent system.

Agents:
1. **Supervisor** — routes each request to an agent. All agents always return to the supervisor. The supervisor must **never** answer anything not about HDB (implement as a separate, testable guardrail step, not just a prompt line). Needs max-hop limit + explicit FINISH route.
2. **RAG agent** — answers HDB policy questions from a scraped corpus.
3. **House price analysis agent** — text-to-SQL over the resale dataset. Security: read-only DB role, SELECT-only validation, row limit, statement timeout, access to the clean view only.
4. **Geospatial agent** — STRETCH GOAL, PARKED. No PostGIS for now.

## Confirmed decisions
| Area | Decision |
|---|---|
| Agent framework | LangGraph |
| LLM | Provider-interchangeable; OpenAI GPT-4o for now |
| Embeddings | OpenAI (`text-embedding-3-small`, 1536-d) for now |
| Architecture | Microservices, option **B**: each agent is its own service; supervisor calls agents over HTTP |
| Inter-service contract | FastAPI + Pydantic (shared `contracts` package) |
| SQL store | Postgres (resale data + LangGraph Postgres checkpointer) |
| Vector store | Qdrant (chosen for built-in hybrid search) |
| Conversation memory | Yes, multi-turn, via LangGraph Postgres checkpointer |
| UI | Streamlit frontend → FastAPI gateway |
| Evals / tracing | DeepEval (RAGAS seen as stagnant) / LangSmith |
| Orchestration | Docker Compose first; Kubernetes later (build 12-factor / k8s-ready) |
| Repo | Monorepo, uv workspace; separate git repo for this project |
| Docker security | Pinned digests, slim/distroless multi-stage, non-root, no-new-privileges, cap_drop ALL, read-only rootfs, no baked secrets, internal networks, no docker.sock, healthchecks, resource limits, Trivy scans |
| Data modelling | `resale_raw` (all text) + typed `resale_transactions` view; agent sees the view only |
| Data loading | One-shot loader container + Alembic migrations |
| Data refresh | Monthly, manual. MVP = stable one-time load |
| Testing | pytest + testcontainers (real Postgres/Qdrant, no DB mocks) |
| Tooling | ruff, pyright, pytest, pre-commit, Makefile |
| Decision records | ADRs in `docs/adr/` (user is new to ADRs; explain as we go) |
| Commits | One per step, Conventional Commits, on feature branches |

## Data: `data/hdb_resale_prices.csv`
data.gov.sg resale prices, from 2017-01; ~244,657 rows; 24 MB. No coordinates.
Columns: `month` (YYYY-MM), `town`, `flat_type`, `block`, `street_name`, `storey_range` ("10 TO 12"), `floor_area_sqm`, `flat_model`, `lease_commence_date` (year), `remaining_lease` ("61 years 04 months"), `resale_price`.

## On hold
- **Scraper / RAG corpus**: the user owns the scraper code. Do not build one. The scraper's output format (which decides the `PolicyDocument` contract) is unknown. Wait for the user.
- Chunking strategy: deferred until the corpus is seen.

See `HANDOFF.md` for current status and the approved plan for Feature 1.
