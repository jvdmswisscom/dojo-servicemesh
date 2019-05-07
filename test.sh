#!/bin/bash


type=$1
fails=""

inspect() {
  if [ $1 -ne 0 ]; then
    fails="${fails} $2"
  fi
}

dup() {
  docker-compose -f docker-compose.yml up -d --build
}

ddown() {
  docker-compose -f docker-compose.yml down
}

# run server-side tests
server() {
  docker-compose -f docker-compose.yml run users python manage.py test
  inspect $? users
  docker-compose -f docker-compose.yml run users flake8 project
  inspect $? users-lint
  docker-compose -f docker-compose.yml run exercises python manage.py test
  inspect $? exercises
  docker-compose -f docker-compose.yml run exercises flake8 project
  inspect $? exercises-lint
  docker-compose -f docker-compose.yml run scores python manage.py test
  inspect $? scores
  docker-compose -f docker-compose.yml run scores flake8 project
  inspect $? scores-lint
}

# run client-side tests
client() {
  docker-compose -f docker-compose.yml run client npm test -- --coverage
  inspect $? client
}

# run e2e tests
e2e() {
  export REACT_APP_API_GATEWAY_URL=https://nxxxox5cyg.execute-api.eu-west-1.amazonaws.com/v1/execute
  export LOAD_BALANCER_DNS_NAME=localhost
  docker-compose -f docker-compose.yml run users python manage.py recreate-db
  ./node_modules/.bin/cypress run --config baseUrl=http://localhost --env REACT_APP_API_GATEWAY_URL=$REACT_APP_API_GATEWAY_URL,LOAD_BALANCER_DNS_NAME=$LOAD_BALANCER_DNS_NAME
  # ./node_modules/.bin/cypress open --config baseUrl=http://localhost --env REACT_APP_API_GATEWAY_URL=$REACT_APP_API_GATEWAY_URL,LOAD_BALANCER_DNS_NAME=$LOAD_BALANCER_DNS_NAME
  unset REACT_APP_API_GATEWAY_URL LOAD_BALANCER_DNS_NAME
  inspect $? e2e
}

# run all tests
all() {
  server
  client
  e2e
}

# run appropriate tests
if [[ "${type}" == "server" ]]; then
  echo "\n"
  echo "Running server-side tests!\n"
  dup
  server
  ddown
elif [[ "${type}" == "client" ]]; then
  echo "\n"
  echo "Running client-side tests!\n"
  dup
  client
  ddown
elif [[ "${type}" == "e2e" ]]; then
  echo "\n"
  echo "Running e2e tests!\n"
  dup
  e2e
  ddown
elif [[ "${type}" == "all" ]]; then
  echo "\n"
  echo "Running all tests!\n"
  dup
  all
  ddown
else
  echo "\n"
  echo "test.sh [server|client|e2e|all]\n"
  exit 1
fi

# return proper code
if [ -n "${fails}" ]; then
  echo "\n"
  echo "Tests failed: ${fails}"
  exit 1
else
  echo "\n"
  echo "Tests passed!"
  exit 0
fi
