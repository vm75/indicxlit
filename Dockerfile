# Build stage - compile dependencies
FROM python:3.9-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    g++ \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir ai4bharat-transliteration flask flask-cors

# Runtime stage - minimal image
FROM python:3.9-slim

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Set environment to use the venv
ENV PATH="/opt/venv/bin:$PATH"

# Create the launcher script
RUN echo 'from ai4bharat.transliteration import xlit_server; app, engine = xlit_server.get_app(); app.run(host="0.0.0.0", port=4321)' > app.py

EXPOSE 4321
CMD ["python", "app.py"]
