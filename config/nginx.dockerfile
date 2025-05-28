FROM nginx:latest
ENV NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx
COPY *.conf.template /etc/nginx/templates/
