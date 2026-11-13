# HomeMe

"Home me!" A multi-agent Q&A system for Singapore HDB housing: policy questions (RAG) and resale price analysis (text-to-SQL), coordinated by a supervisor agent.

## Layout

```
packages/contracts/      shared Pydantic models between services
services/db-migrations/  Alembic: Postgres schema, views, grants
services/resale-loader/  one-shot: CSV -> Postgres
services/vector-init/    one-shot: create the Qdrant collection
docs/adr/                architecture decision records
data/                    git-ignored; see data/README.md
```

## Getting started

Needs [uv](https://docs.astral.sh/uv/), GNU Make, and Docker (for integration tests and the stack).

```sh
make install   # dependencies + git hooks
make check     # everything CI runs
make help      # all targets
```

Get the dataset: see [data/README.md](data/README.md).
