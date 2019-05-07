#!/bin/bash

# start db services
docker-compose -f docker-compose.yml up -d users-db scores-db exercises-db

# create
docker-compose -f docker-compose.yml run exercises python manage.py recreate-db
docker-compose -f docker-compose.yml run users python manage.py recreate-db
docker-compose -f docker-compose.yml run scores python manage.py recreate-db
# seed
docker-compose -f docker-compose.yml run exercises python manage.py seed-db
docker-compose -f docker-compose.yml run users python manage.py seed-db
docker-compose -f docker-compose.yml run scores python manage.py seed-db
