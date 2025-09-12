#!/bin/sh
# This script sets up the Django environment for a container or a fresh installation.

# Exit immediately if a command exits with a non-zero status.
set -e

# ---
# Configure environment variables
# ---

# Ensure the .env file exists.
touch .env

# Generate a new Django SECRET_KEY if it's not already set in the .env file.
if ! grep -q "^DJANGO_SECRET_KEY=" .env; then
  echo "DJANGO_SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')" >> .env
fi

# Set default values for superuser credentials if they aren't provided as environment variables.
: "${DJANGO_SUPERUSER_USERNAME:=admin}"
: "${DJANGO_SUPERUSER_EMAIL:=admin@example.com}"
: "${DJANGO_SUPERUSER_PASSWORD:=password}"

# ---
# Apply database migrations
# ---

echo "Applying database migrations..."
python manage.py migrate

# ---
# Create superuser if it doesn't already exist
# ---

echo "Creating superuser '${DJANGO_SUPERUSER_USERNAME}' if it doesn't exist..."
# The logical OR (||) operator in Python's evaluation ensures that create_superuser is only called
# if the filter(...) returns an empty queryset (which evaluates to False).
python manage.py shell -c "from django.contrib.auth import get_user_model; \
User = get_user_model(); \
username = '${DJANGO_SUPERUSER_USERNAME}'; \
email = '${DJANGO_SUPERUSER_EMAIL}'; \
password = '${DJANGO_SUPERUSER_PASSWORD}'; \
if not User.objects.filter(username=username).exists(): \
    User.objects.create_superuser(username=username, email=email, password=password); \
    print(f'Superuser {username} created successfully.'); \
else: \
    print(f'Superuser {username} already exists. Skipping creation.');"

# ---
# Start the main process (e.g., development server)
# ---

# Execute the command passed to the script (e.g., 'python manage.py runserver 0.0.0.0:8000')
echo "Starting Django server..."
exec "$@"