# Stage 1: Builder stage
FROM python:3.11-buster AS builder

# Set the working directory
WORKDIR /app

# Upgrade pip and install Poetry
RUN pip install --upgrade pip && pip install poetry

# Copy the dependency files
COPY pyproject.toml poetry.lock ./

# Install dependencies without creating a virtual environment
RUN poetry config virtualenvs.create false \
    && poetry install --no-root --no-interaction --no-ansi

# Copy the application code
COPY . .

# Stage 2: Final app stage
FROM python:3.11-buster

# Set the working directory
WORKDIR /app

# Copy the installed dependencies and application code from the builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app /app

# Copy the entrypoint script and set permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port 8000 for FastAPI
EXPOSE 800

# Set the entrypoint and default command
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
