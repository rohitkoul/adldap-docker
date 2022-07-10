# Troll Active Directory (AD)

This is essentially an Apache Directory Server (ApacheDS) with some Active Directory (AD) specific attributes added to make it feel like AD ; done primarily for testing purposes.  

#### References
* embedded ApacheDS from github.com/intoolswetrust/ldap-server 
* http://stackoverflow.com/questions/11174835/add-memberof-attribute-to-apacheds
* The work to add memberOf attribute in ApacheDS is tracked here https://issues.apache.org/jira/browse/DIRSERVER-1844
 


### Make Fu
A `Makefile` is provided for convenience, though a part of me considers it abusing Makefiles.

1. Run `make help` to see various supported commands.
2. For the uninitiated, `make build` builds the image as `adtest:1.0.0` and `make run` runs it.
3. `make runssl` starts the TLS listener as well. 

you may want to check out the help menu for more details

### Docker Fu

#### Run

you can run it with the default data and config

```
   docker run -it --rm -p 127.0.0.1:10389:10389  rkoul/adldap-docker:1.0.0
```
Or pass your own users/groups ldif file via a bind mount 

```
	docker run -v /tmp/data:/ldap/data \
	    -e LDAP_USER_LDIF=myusers.ldif \
		-e LDAP_ADMIN_PASSWORD=secret \
		-e LDAP_DEBUG=true \
		-it --rm -p 127.0.0.1:10389:10389  rkoul/adldap-docker:1.0.0

```
For LDAPS, you can add a java keystore file in the mounted dir. (see `make keystore`)

```
	docker run -v /tmp/data:/ldap/data \
	    -e LDAP_USER_LDIF=myusers.ldif \
		-e LDAP_ADMIN_PASSWORD=secret \
		-e LDAP_KEYSTORE=mykeystore.jks \
		-e LDAP_KEYSTORE_PASSWORD=mypass \
		-e LDAP_DEBUG=true \
		-it --rm -p 127.0.0.1:10636:10636 rkoul/adldap-docker:1.0.0
```

#### Local Build
if you make changes, you can clone this repo and build a new version as under:

```
docker build -t adldap:1.0.0 .

```

### Sample dataset

* default LDAP admin bind credentials are `uid=admin,ou=system` and whatever is passed as `LDAP_ADMIN_PASSWORD`
* the rest of the sample data is in `data/records.ldif`  (the schema gets created via `extensions.ldif`)
* user basedn = `ou=users,dc=example,dc=com`
* groups basedn = `ou=groups,dc=example,dc=com`
* user password = `secret`

| cn | full name | uid | mail | groups |
|---|---|---|---|----|
|rohit| Rohit Koul |rkoul| rohit.koul@example.com | piedpiper, trinity, threecommaclub |
|richard| Richard Hendricks| rhendricks| richard.hendricks@example.com|piedpiper, trinity|
|gilfoyle| Bertram Gilfoyle| bgilfoyle | bertram.gilfoyle@example.com|piedpiper|
|erlich| Erlich Bachman |ebachman| erlich.bachman@example.com| piedpiper, aviato|
|jianyang| Jian Yang | jyang | jian.yang@example.com| piedpiper|
|gavin| Gavin Belson |gbelson| gavin.belson@example.com |hooli|
|russ| Russ Hanneman |rhanneman| russ.hanneman@example.com|threecommaclub|
|bighead| Nelson Bighetti| bnelson|nelson.bighetti@example.com|hooli|
|jared| Donald Dunn |jared |donald.dunn@example.com|piedpiper, hooli|
|dinesh| Dinesh Chugtai| dchugtai| dinesh.chugtai@example.com|piedpiper|
|monica| Monica Hall |mhall | monica.hall@example.com|raviga|
|laurie| Laurie Bream |lbream| laurie.bream@example.com| raviga |
|anton| Anton Server| anton| anton.server@example.com| - |

There are also users `adminuser`, `testuser` & groups `admins` and `testers` should you just care for generic ones. Use an LDAP browser and look at it.