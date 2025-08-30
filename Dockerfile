# syntax=docker/dockerfile:1

FROM python:3.11-slim AS base

# Set workdir for all stages
WORKDIR /app

# --- Builder stage ---
FROM base AS builder

# Install build dependencies (if any needed for pip install, e.g. for psycopg2, Pillow, etc.)
# For this project, requirements.txt only has pure Python deps, so no build deps needed.

# Copy requirements.txt only (for better cache usage)
COPY --link requirements.txt ./

# Create venv and install dependencies using pip cache
RUN python -m venv .venv \
    && .venv/bin/pip install --upgrade pip \
    && --mount=type=cache,target=/root/.cache/pip \
       .venv/bin/pip install -r requirements.txt

# Copy application code (excluding venv, .git, etc.)
COPY --link core ./core
COPY --link inventory ./inventory
COPY --link tenants ./tenants
COPY --link manage.py ./manage.py

# --- Final stage ---
FROM base AS final

# Create non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

# Copy venv from builder
COPY --from=builder /app/.venv /app/.venv

# Copy application code from builder
COPY --from=builder /app/core ./core
COPY --from=builder /app/inventory ./inventory
COPY --from=builder /app/tenants ./tenants
COPY --from=builder /app/manage.py ./manage.py

# Set environment variables
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set permissions
RUN chown -R appuser:appgroup /app
USER appuser

# Expose port 8000 (Django default)
EXPOSE 8000

# Default command: run Django development server (override in production)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
