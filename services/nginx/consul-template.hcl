consul = "consul:8500"
log_level = "INFO"
template {
  source = "/etc/consul-template/upstream.ctmpl"
  destination = "/etc/nginx/conf.d/upstream.conf"
  command = "/usr/sbin/nginx -s reload"
}
