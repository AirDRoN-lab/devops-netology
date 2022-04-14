FROM centos:latest

RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
#RUN yum update -y
RUN yum install -y wget
RUN wget https://fossies.org/linux/www/elasticsearch-8.1.2-linux-x86_64.tar.gz
RUN tar -xzf elasticsearch-8.1.2-linux-x86_64.tar.gz
RUN echo "node.name: netology.test" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "path.data: /var/lib/elastic" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "xpack.security.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "xpack.security.enrollment.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "xpack.security.http.ssl.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "xpack.security.transport.ssl.enabled: false" >> /elasticsearch-8.1.2/config/elasticsearch.yml

#RUN echo ES_HOME='/elasticsearch-8.1.2'

RUN groupadd elasticsearch
RUN useradd elasticsearch -g elasticsearch -p elasticsearch
RUN mkdir /var/lib/elastic
RUN chown -R elasticsearch:elasticsearch /elasticsearch-8.1.2
RUN chmod o+x /elasticsearch-8.1.2
RUN chgrp elasticsearch /elasticsearch-8.1.2
RUN chown -R elasticsearch:elasticsearch /var/lib/elastic
RUN chmod o+x /var/lib/elastic
RUN chgrp elasticsearch /var/lib/elastic
RUN echo "vm.max_map_count = 262144" >> /etc/sysctl.conf
RUN echo "network.host: 0.0.0.0" >> /elasticsearch-8.1.2/config/elasticsearch.yml
RUN echo "discovery.type: single-node" >> /elasticsearch-8.1.2/config/elasticsearch.yml

CMD su - elasticsearch -c /elasticsearch-8.1.2/bin/elasticsearch
