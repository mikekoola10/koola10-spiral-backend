# Multi-stage: Base Python 3.12 slim for speed
FROM python:3.12-slim AS base

# Install deps (system-level for Playwright/Browser Use)
RUN apt-get update && apt-get install -y \
    wget gnupg \
    && rm -rf /var/lib/apt/lists/*

# Playwright setup for scrapes
RUN pip install playwright && playwright install --with-deps chromium

# Copy & Install Python deps
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy code
COPY . .

# Expose ports (Gateway primary; others internal)
EXPOSE 8000 8001 8002

# Multi-service entry (Run Compose or sequential; for monolith, start Gateway as entry)
CMD ["sh", "-c", "uvicorn gateway:app --host 0.0.0.0 --port 8000 & uvicorn mcp_server:app --host 0.0.0.0 --port 8001 & python orchestrator.py"]
