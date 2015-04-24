FROM mondary/debian-base

ENTRYPOINT ["/opt/consul-template/consul-template"]

RUN mkdir -p /opt/consul-template && \
    curl -SL https://github.com/hashicorp/consul-template/releases/download/v0.8.0/consul-template_0.8.0_linux_amd64.tar.gz \
    | tar -xvzC /opt/consul-template && \
    mv /opt/consul-template/consul-template_0.8.0_linux_amd64/consul-template /opt/consul-template/consul-template && \
    rm -rf /opt/consul-template/consul-template_0.8.0_linux_amd64

RUN mkdir -p /templates
VOLUME /templates
