FROM debian:sid

MAINTAINER Ilya Epifanov <elijah.epifanov@gmail.com>

RUN apt-get update \
 && apt-get install -y curl ca-certificates --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)" \
 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture).asc" \
 && gpg --verify /usr/local/bin/gosu.asc \
 && rm /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu

RUN apt-get update \
 && apt-get install -y openjdk-8-jre-headless openjdk-8-jdk --no-install-recommends \
 && dpkg-reconfigure ca-certificates-java \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -r teamcity-agent \
 && useradd -r -d /var/lib/teamcity-agent -m -g teamcity-agent teamcity-agent

ENV TEAMCITY_VERSION=9.1.3

RUN curl -o /tmp/teamcity.tar.gz -SL "http://download.jetbrains.com/teamcity/TeamCity-${TEAMCITY_VERSION}.tar.gz" \
 && mkdir /tmp/teamcity \
 && tar xf /tmp/teamcity.tar.gz --strip-components 1 -C /tmp/teamcity \
 && rm /tmp/teamcity.tar.gz \
 && cp -RT /tmp/teamcity/buildAgent /var/lib/teamcity-agent \
 && mkdir -p /var/lib/teamcity-agent/logs \
 && rm /var/lib/teamcity-agent/conf/buildAgent.properties \
 && rm -Rf /tmp/teamcity \
 && chown -R teamcity-agent /var/lib/teamcity-agent

VOLUME /var/lib/teamcity-agent/logs /var/lib/teamcity-agent/work

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

ENV TEAMCITY_AGENT_OPTS=""
ENV TEAMCITY_AGENT_MEM_OPTS="-mx256m -XX:+UseG1GC -XX:+UseStringDeduplication"

EXPOSE 8002
CMD ["/var/lib/teamcity-agent/bin/agent.sh", "run"]
