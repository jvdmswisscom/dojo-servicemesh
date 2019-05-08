#!/bin/sh

# start nginx
nginx

sleep 2

# start consul-template
consul-template -config /etc/consul-template/consul-template.hcl
