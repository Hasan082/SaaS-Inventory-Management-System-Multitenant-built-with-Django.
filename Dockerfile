# Use Official Python slim image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Set working directory
WORKDIR /app

# Copy requirements from root (context is project root)
COPY requirements.txt .

# Install dependencies
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project
COPY . .

# Copy entrypoint and make it executable
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Expose the port
EXPOSE 8000

# Use exec form for ENTRYPOINT to correctly handle arguments
ENTRYPOINT ["./entrypoint.sh"]

# Pass CMD arguments to the ENTRYPOINT script
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]