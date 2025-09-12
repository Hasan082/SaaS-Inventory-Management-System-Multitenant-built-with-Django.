#!/bin/sh
# Exit on error
set -e


# Ensure .env exists and DJANGO_SECRET_KEY is set
touch .env
if ! grep -q "^DJANGO_SECRET_KEY=" .env; then
  echo "DJANGO_SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')" >> .env
fi


# Apply database migrations
python manage.py migrate

# Collect static files (optional, uncomment if needed)
# python manage.py collectstatic --noinput


# Create superuser if not exists
echo "from django.contrib.auth import get_user_model; \
User = get_user_model(); \
username = '${DJANGO_SUPERUSER_USERNAME}'; \
email = '${DJANGO_SUPERUSER_EMAIL}'; \
password = '${DJANGO_SUPERUSER_PASSWORD}'; \
User.objects.filter(username=username).exists() or \
User.objects.create_superuser(username=username, email=email, password=password)" \
| python manage.py shell

# Start Django development server
exec "$@"
