FROM nginx:latest
COPY nginx.conf /etc/nginx/nginx.conf
COPY *.conf.template /etc/nginx/templates/
