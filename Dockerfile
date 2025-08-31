# Use Official Python slim image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Set working directory
# Dockerfile.dev
WORKDIR /app

# Copy requirements from root (context is project root)
COPY requirements.txt .

# Install dependencies
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project
COPY . .

COPY entrypoint.sh .

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Expose the port
EXPOSE 8000

# Use entrypoint script
ENTRYPOINT ["./entrypoint.sh"]

# Development server with hot reload
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]