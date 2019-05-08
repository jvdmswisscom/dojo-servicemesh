#!/bin/bash
set -e

echo "Waiting for postgres..."

while ! nc -z users-db 5432; do
  sleep 0.1
done

echo "PostgreSQL started"

# consul service registration configuration
IPADDR=`ip a show eth0 | grep -oP 'inet \K[\d\.]+'`

cat <<EOF | tee /etc/consul.d/${CONSUL_SERVICE}.json
{
  "service": {
    "name": "${CONSUL_SERVICE}",
    "port": 5000
  }
}
EOF

# start consul agent
nohup consul agent \
	-bind=${IPADDR} \
	-retry-join=consul \
	--data-dir=/var/consul \
	-config-dir=/etc/consul.d \
	&

sleep 2

# testdriven service 
python manage.py recreate-db
python manage.py seed-db
gunicorn -b 0.0.0.0:5000 manage:app
