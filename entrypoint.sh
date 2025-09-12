#!/bin/sh
# Exit on error
set -e

# Apply database migrations
python manage.py migrate

# Collect static files (optional, uncomment if needed)
# python manage.py collectstatic --noinput

# Start Django development server
exec "$@"
