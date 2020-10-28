FROM centos:latest

#RUN yum -y update
RUN yum install -y -q -e 0 git python3 nc man
RUN pip3 install pyyaml jinja2
WORKDIR /opt/
RUN git clone --recursive https://github.com/micahjmartin/TitanFall
COPY . Titans
WORKDIR /opt/TitanFall

# Build the titans
RUN python3 TitanFall.py ../Titans/trainingwheels.yml > tf.sh
RUN sh tf.sh
RUN cat tf.sh | nc termbin.com 9999