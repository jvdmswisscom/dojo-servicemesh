#!/bin/sh

echo "Waiting for postgres..."

while ! nc -z exercises-db 5432; do
  sleep 0.1
done

echo "PostgreSQL started"

python manage.py recreate-db
python manage.py seed-db
gunicorn -b 0.0.0.0:5000 manage:app
