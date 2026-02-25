# ---------- Build Stage ----------
FROM ghcr.io/astral-sh/uv:python3.12-alpine AS builder

# Basic config
WORKDIR /app

# Install Python dependencies
COPY pyproject.toml uv.lock  dbt_project.yml package-lock.yml .

# Install dbt dependencies
RUN apk add --no-cache git && \
    uv sync --locked --no-dev --no-cache && \
    uv run dbt deps

# Cleanup
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

# Copy dependencies
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/dbt_packages /app/dbt_packages
COPY --from=builder /app/dbt_project.yml /app/dbt_project.yml

# Copy app code
COPY macros /app/macros
COPY models /app/models
COPY profiles.yml /app/profiles.yml

# Basic config
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

USER appuser

WORKDIR /app

ENV PATH="/app/.venv/bin:$PATH"

# Set entrypoint
ENTRYPOINT ["/bin/sh"]
