#FROM nginx:1.15.0-alpine
FROM opentracing/nginx-opentracing

# install consul-template
RUN wget https://releases.hashicorp.com/consul-template/0.20.0/consul-template_0.20.0_linux_amd64.tgz -O /tmp/consul-template.tgz
RUN tar xvzf /tmp/consul-template.tgz -C /usr/local/bin

RUN mkdir /etc/consul-template
COPY /consul-template.hcl /etc/consul-template
COPY /upstream.ctmpl /etc/consul-template

# nginx config
RUN rm /etc/nginx/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf
COPY /nginx.conf /etc/nginx/nginx.conf
COPY /server.conf /etc/nginx/conf.d
COPY /zipkin-config.json /etc/zipkin-config.json

# add entrypoint.sh
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
