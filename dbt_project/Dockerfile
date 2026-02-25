# ---------- Build Stage ----------
FROM ghcr.io/astral-sh/uv:python3.12-alpine AS builder

WORKDIR /app

COPY pyproject.toml uv.lock  dbt_project.yml package-lock.yml .

RUN apk add --no-cache git

RUN uv sync \
    --no-dev \
    --no-cache \
    --no-python-downloads \
    --no-install-project \
    --no-editable \
    --locked \
    --link-mode=copy

RUN uv run dbt deps

RUN find /app/.venv -type d -name __pycache__ -exec rm -rf {} + && \
    find dbt_packages \
        -mindepth 2 \
        ! -name "dbt_project.yml" \
        ! -name "packages.yml" \
        ! -path "**/macros" \
        ! -path "**/macros/*" \
        -exec rm -rf {} +

# ---------- Runtime Stage ----------
FROM python:3.12-alpine AS runner

RUN addgroup -S -g 1001 app && \
    adduser -S -g 1001 -u 1001 -G app app

COPY --from=builder --chown=app:app /app/.venv /app/.venv
COPY --from=builder --chown=app:app /app/dbt_packages /app/dbt_packages
COPY --from=builder --chown=app:app /app/dbt_project.yml /app/dbt_project.yml

COPY --chown=app:app macros /app/macros
COPY --chown=app:app models /app/models
COPY --chown=app:app profiles.yml /app/profiles.yml

ENV PATH="/app/.venv/bin:$PATH"

USER app

WORKDIR /app

ENTRYPOINT ["dbt"]
CMD ["--help"]
