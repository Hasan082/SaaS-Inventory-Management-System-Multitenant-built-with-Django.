#!/bin/sh
# Django entrypoint script for containers
# Handles database migrations, superuser creation, and server startup

set -e

# Load environment variables from .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Generate DJANGO_SECRET_KEY if empty
if [ -z "$DJANGO_SECRET_KEY" ]; then
  SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
  echo "DJANGO_SECRET_KEY=$SECRET_KEY" >> .env
  export DJANGO_SECRET_KEY=$SECRET_KEY
  echo "Generated DJANGO_SECRET_KEY: $SECRET_KEY"
fi

# ---
# Utility functions
# ---

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
    exit 1
}

# ---
# Environment validation
# ---

log "Starting Django application setup..."

# Check if manage.py exists
if [ ! -f "manage.py" ]; then
    error "manage.py not found. Run this script from Django project root"
fi

# Check Django installation
if ! python -c "import django" 2>/dev/null; then
    error "Django not installed or not accessible"
fi

# ---
# Environment configuration
# ---

# Create .env file if it doesn't exist
touch .env

# Generate Django SECRET_KEY if not present
if ! grep -q "^DJANGO_SECRET_KEY=" .env; then
    log "Generating Django SECRET_KEY..."
    SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
    echo "DJANGO_SECRET_KEY=${SECRET_KEY}" >> .env
fi

# Set default superuser credentials
: "${DJANGO_SUPERUSER_USERNAME:=admin}"
: "${DJANGO_SUPERUSER_EMAIL:=admin@example.com}"
: "${DJANGO_SUPERUSER_PASSWORD:=password}"

# ---
# Database setup
# ---

log "Applying database migrations..."
python manage.py migrate

log "Creating superuser if needed..."
# Create superuser if not exists
python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
username = '$DJANGO_SUPERUSER_USERNAME'
password = '$DJANGO_SUPERUSER_PASSWORD'
email = '$DJANGO_SUPERUSER_EMAIL'
user, created = User.objects.get_or_create(username=username, defaults={'email': email, 'is_staff': True, 'is_superuser': True, 'is_active': True})
if created:
    user.set_password(password)
    user.save()
    print('Superuser created:', username)
else:
    print('Superuser already exists:', username)
"

# ---
# Static files (optional)
# ---

if python manage.py help collectstatic >/dev/null 2>&1; then
    log "Collecting static files..."
    python manage.py collectstatic --noinput --clear >/dev/null 2>&1 || true
fi

# ---
# Start application
# ---

log "Setup complete! Starting application..."
log "Superuser: ${DJANGO_SUPERUSER_USERNAME} / ${DJANGO_SUPERUSER_EMAIL}"

exec "$@"