FROM ruby:2.0.0-p643-slim

RUN mkdir /root/.ssh/

RUN apt-get update && \
    apt-get install -y git zip wget && \
    touch /root/.ssh/known_hosts && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    gem install aws-sdk

RUN wget https://github.com/coreos/fleet/releases/download/v0.10.0/fleet-v0.10.0-linux-amd64.tar.gz && \
    tar -xzvf fleet-v0.10.0-linux-amd64.tar.gz && \
    mv fleet-v0.10.0-linux-amd64/fleetctl ./

RUN mkdir /keys
VOLUME /keys

RUN mkdir /services
VOLUME /services

ADD fleet.rb ./fleet.rb
ADD start.sh ./start.sh

RUN chmod +x fleet.rb && \
    chmod +x start.sh

ENTRYPOINT ["./start.sh"]
