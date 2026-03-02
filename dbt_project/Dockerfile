# ---------- Build Stage ----------
FROM ghcr.io/astral-sh/uv:python3.12-alpine AS builder

WORKDIR /app

# Install Python dependencies
COPY pyproject.toml uv.lock .

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync \
    --no-dev \
    --no-python-downloads \
    --no-install-project \
    --no-editable \
    --locked \
    --link-mode=copy

# Install dbt dependencies
COPY dbt_project.yml package-lock.yml .
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv run dbt deps

# Remove Python cache
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

# Create non-root user
RUN addgroup -S -g 1000 app && \
    adduser -S -g 1000 -u 1000 -G app app

# Install git (necessary for dbt deps)
RUN apk add --no-cache git

# Copy dependencies
COPY --from=builder --chown=app:app /app/.venv /app/.venv
COPY --from=builder --chown=app:app /app/dbt_packages /app/dbt_packages
COPY --from=builder --chown=app:app /app/dbt_project.yml /app/dbt_project.yml

# Copy app code
COPY --chown=app:app macros /app/macros
COPY --chown=app:app models /app/models
COPY --chown=app:app profiles.yml /app/profiles.yml

# Configure environment variables
ENV HOME=/app \
    PATH=/app/.venv/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Switch to non-root user
USER app

# Set working directory
WORKDIR /app

# Configure execution
ENTRYPOINT ["dbt"]
CMD ["--help"]
