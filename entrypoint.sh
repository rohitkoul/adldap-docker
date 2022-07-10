#!/bin/sh
CONTAINER_DATA_DIR="/ldap/data"
DEFAULT_USER_LDIF="records.ldif"
DEFAULT_LDAP_KEYSTORE="ad.ldaps.keystore"
DEFAULT_LDAP_ADMIN_PASSWORD="secret"
DEFAULT_LDAP_DEBUG="false"

LDAP_USER_LDIF=${LDAP_USER_LDIF:-$DEFAULT_USER_LDIF}
LDAP_KEYSTORE=${LDAP_KEYSTORE:-$DEFAULT_LDAP_KEYSTORE}
LDAP_ADMIN_PASSWORD=${LDAP_ADMIN_PASSWORD:-$DEFAULT_LDAP_ADMIN_PASSWORD}
LDAP_DEBUG=${LDAP_DEBUG:-$DEFAULT_LDAP_DEBUG}

LDAP_BIND_ADDRESS="0.0.0.0"
LDAP_BIND_PORT="10389"
LDAP_SSL_PORT="10636"

user_ldif_path="${CONTAINER_DATA_DIR}/${LDAP_USER_LDIF}"
dopts=""

if [ "${LDAP_DEBUG}" == "true" ]
then
    echo "------------------------------------"
    echo LDAP_USER_LDIF=${LDAP_USER_LDIF}
    echo LDAP_KEYSTORE=${LDAP_KEYSTORE}
    echo LDAP_ADMIN_PASSWORD=${LDAP_ADMIN_PASSWORD}
    echo "-----------------------------------"
    dopts="-Djavax.net.debug=all"
fi

if [ ! -f ${user_ldif_path} ]
then
    echo "No file ${user_ldif_path} found"
    exit 1
else
    rm ${CONTAINER_DATA_DIR}/combined.ldif 2>/dev/null
    cat /ldap/extensions.ldif ${user_ldif_path} > ${CONTAINER_DATA_DIR}/combined.ldif 
fi

ssl_string=""
# switch on keystore password for now for now ; 
# may be add a SSL_MODE=true|false later
if [ ! -z ${LDAP_KEYSTORE_PASSWORD} ]
then
    keystore_path="${CONTAINER_DATA_DIR}/${LDAP_KEYSTORE}"
    if [ ! -f ${keystore_path} ]
    then
        echo "No keystore ${keystore_path} found"
        exit 1
    fi
    ssl_string=" --ssl-port ${LDAP_SSL_PORT} --ssl-keystore-file ${keystore_path} --ssl-keystore-password ${LDAP_KEYSTORE_PASSWORD} "
    if [ "${LDAP_DEBUG}" == "true" ]
    then
        echo "-----------------------------------"
        echo LDAP_KEYSTORE=${LDAP_KEYSTORE}
        echo LDAP_KEYSTORE_PASSWORD=${LDAP_KEYSTORE_PASSWORD}
        echo "-----------------------------------"
    fi
fi

now=$(date '+%Y%m%d%H%M%S.0Z')
sed -i.bak 's/%TOKEN%/'${now}'/g' /ldap/data/combined.ldif
rm /ldap/data/combined.ldif.bak 2>/dev/null

exec java ${dopts} -jar \
    /ldap/ldap-server.jar \
    --admin-password "${LDAP_ADMIN_PASSWORD}" \
    --bind  "${LDAP_BIND_ADDRESS}" \
    --port  "${LDAP_BIND_PORT}" ${ssl_string} /ldap/data/combined.ldif "$@"




