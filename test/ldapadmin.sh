#!/bin/bash
if [ -z $1 ]
then
 ip=$(docker inspect troll-ad-server | jq -r '.[].NetworkSettings.Networks[].IPAddress')
 ret=$?
 if [ $ret -ne 0 ]
 then
     echo error
     exit $ret
 fi
else
 ip="$1"
fi

echo "LDAP=${ip}:10389"
LDAP_STR="ldap://${ip}:10389"

docker run -p 8080:80 \
    -e LDAP_URL=${LDAP_STR} \
    -e LDAP_BASE="dc=example,dc=com" \
    -e LDAP_ADMIN="uid=admin,ou=system" \
    -d --rm rschaeuble/phpldapadmin:latest

echo "Check localhost:8080"

