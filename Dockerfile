FROM openjdk:8u111-jre-alpine
MAINTAINER Rohit Koul "4hg1q1q9v@mozmail.com"
ARG LDAP_RELEASE=v.1.0.0

RUN apk add --no-cache openssl \
   && addgroup -g 1337 -S adldap  \
   && adduser -u 1337 -S adldap -G adldap  \
   && mkdir -p /ldap \
   && wget -O /ldap/ldap-server.jar https://github.com/intoolswetrust/ldap-server/releases/download/${LDAP_RELEASE}/ldap-server.jar

COPY extensions.ldif /ldap
COPY entrypoint.sh /ldap
COPY data /ldap/data
RUN  chmod +x /ldap/entrypoint.sh && chown -R adldap:adldap /ldap

EXPOSE 10389
USER adldap
ENTRYPOINT [ "/ldap/entrypoint.sh" ]


