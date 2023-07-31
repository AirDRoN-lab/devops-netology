FROM nginx:alpine
LABEL maintainer="dm.golodnikov@gmail.com"

COPY index.html ./usr/share/nginx/html/index.html
#ARG mac=$(ip a | grep ether | awk '{print $2}')

EXPOSE 80