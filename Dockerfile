FROM nginx:1.27.2

COPY ./frpc .
COPY ./frpc.yaml .

COPY <<EOF /etc/nginx/conf.d/default.conf
server {
  listen 80;
    server_name git.ionitedev.com;
  location / {
    proxy_pass http://gitlab-webservice-default:8181;
  }
}
server {
  listen 80;
    server_name kas.ionitedev.com;
  location /k8s-proxy {
    proxy_pass http://gitlab-kas:8154;
  }
  location / {
    proxy_pass http://gitlab-kas:8150;
  }
}
server {
  listen 80;
    server_name minio.ionitedev.com;
  location / {
    proxy_pass http://gitlab-minio-svc:9000;
  }
}
server {
  listen 80;
    server_name registry.ionitedev.com;
  location / {
    proxy_pass http://gitlab-registry:5000;
  }
}
EOF

COPY nginx-script.sh /docker-entrypoint.sh 
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
