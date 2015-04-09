FROM mondary/java:oracle-java-8

RUN mkdir -p /opt/service
COPY run_dw.sh /opt/service/
RUN chmod +x /opt/service/run_dw.sh

WORKDIR /opt/service

EXPOSE 8080
EXPOSE 9080

ENTRYPOINT ["/opt/service/run_dw.sh"]
