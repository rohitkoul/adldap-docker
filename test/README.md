#### Test
The docker-compose file here starts up `keycloak` for wiring it against the troll AD. 
This serves as a test. Ignore this if you are not familiar with `keycloak`

```
docker-compose up
```

```
docker-compose down [-v]
```

#### LDAP Browser

While `Apache Directory Studio` and `jXplorer` are good, I find the browser based one useful

```

LDAP_STR="ldap://172.17.0.2:10389"

docker run -p 8080:80 \
    -e LDAP_URL=${LDAP_STR} \
    -e LDAP_BASE="dc=example,dc=com" \
    -e LDAP_ADMIN="uid=admin,ou=system" \
    -d --rm rschaeuble/phpldapadmin:latest


```

