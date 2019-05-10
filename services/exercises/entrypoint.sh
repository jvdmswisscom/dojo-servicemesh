#!/bin/sh

echo "Waiting for postgres..."

while ! nc -z exercises-db 5432; do
  sleep 0.1
done

echo "PostgreSQL started"

python manage.py recreate-db
python manage.py seed-db
nohup gunicorn -b 0.0.0.0:5000 manage:app &

# consul service registration configuration
IPADDR=`ip a show eth0 | grep -oP 'inet \K[\d\.]+'`

# define local gunicorn service
cat <<EOF | tee /etc/consul.d/${CONSUL_SERVICE}.json
{
  "service": {
    "name": "${CONSUL_SERVICE}",
    "port": 5000,
    "connect": {
      "sidecar_service": {}
    }
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

# start consul connect proxy
nohup consul connect proxy -sidecar-for ${CONSUL_SERVICE} &
consul connect proxy -service ${CONSUL_SERVICE} -upstream users:5001
