FROM centos:7

RUN yum update -y \
    && yum install -y dracut-fips openssl \
    && yum clean all \
    && rm -rf /var/cache/yum

ENV OPENSSL_FIPS=1
COPY ./fips-cli.sh /usr/bin/fips-cli

ENTRYPOINT [ "/usr/bin/fips-cli" ]
