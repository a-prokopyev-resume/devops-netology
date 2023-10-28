FROM centos:7.9.2009
USER 0
ENV ES_HOME=/usr/share/elasticsearch
RUN yum -y install vim java-11-openjdk java-11-openjdk-devel
COPY elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
RUN yum -y install --enablerepo=elasticsearch elasticsearch
WORKDIR ${HOME}
USER 999
EXPOSE 9200
CMD ["sh", "-c", "${ES_HOME}/bin/elasticsearch"]

