#Download base image ubuntu 22.04
FROM ubuntu:22.04

MAINTAINER Golodnikov Dmitry <dm.golodnikov@gmail.com>

#Configure tz-data
ENV TZ=Asia/Novosibirsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update Ubuntu Software repository and install APP
RUN apt-get -qy update
RUN apt-get install -qy python3 python3-pip software-properties-common git curl apt-transport-https net-tools jq
#RUN apt-get install -qy ansible

# Prepare for install kibectl
#RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add -
#RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list

# Prepare for install helm
#RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
#RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

# Install additional APP from Spec repository
#RUN apt-get -qy update
#RUN apt-get install -y kubectl helm

CMD ["/bin/bash"]
