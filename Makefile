#
#
#

.PHONY: help server build run stop clean

define HELP_TEXT
make help                    Print the help text (this menu).

make build [tag=t]           Build the docker container with tag t.
                             (default t=1.0.0). Same as 'make docker'

make run   [tag=t]           Run the docker container with tag t
           [addr=a][port=p]  on interface a, port p, with bind mount path /m,
           [mount=/m][ldif=f] having ldif file with name f. Also
           [ap=ap]           ldap admin (uid=admin,ou=system) password ap
           [debug=t|f]       (default t=1.0.0, p=10389, addr=0.0.0.0 debug=false
                             mount=$(PWD)/data , ldif=records.ldif, ap=secret).

make runssl [sslport=p]      Similar to 'make run' with additional options
            [ks=ks][ksp=ksp] for ssl viz sslport p 
                             keystore filename ks, keystore password ksp
                             (default sslport=10636, ks=ad.ldaps.keystore
                             ksp=123456).

make stop                    Stop and Kill the docker container
                             started with 'make run' 

make keystore [keystore=/ks] Create a keystore file at path /ks for ssl run
              [storepass=sp] (default keystore=data/ad.ldaps.keystore, storepass=123456
              [dname=distinguished 
              name]          keypass is the same as storepass, dname=adldap.example.com)

make keystorelist [keystore=/ks][storepass=sp] List keystore at path /ks

make clean                   Clean all 'Exited' containers'
endef

img=rkoul/adldap-docker
tag:=1.0.0dev
name:=troll-ad-server

dname=adldap.example.com
keystore=$(PWD)/data/ad.ldaps.keystore
storepass=123456

ldif=records.ldif
ks=ad.ldaps.keystore
ksp=123456
ap=secret
addr=0.0.0.0
port=10389
sslport=10636
mount=$(PWD)/data
debug=false

# Print the help text.
help:
	@: $(info $(HELP_TEXT))

build: docker

# make docker tag=1.0
docker:
	docker build -t ${img}:${tag} .

# make run opts=-d name=foobar mount=/tmp/data 
run: 
	docker run ${opts} --name=${name} -v ${mount}:/ldap/data \
		-e LDAP_USER_LDIF=${ldif} \
		-e LDAP_ADMIN_PASSWORD=${ap} \
		-e LDAP_DEBUG=${debug} \
		-it --rm -p ${addr}:${port}:10389  ${img}:${tag} ${cmd}

runssl: 
	docker run ${opts} --name=${name} -v ${mount}:/ldap/data \
		-e LDAP_USER_LDIF=${ldif} \
		-e LDAP_ADMIN_PASSWORD=${ap} \
		-e LDAP_KEYSTORE=${ks} \
		-e LDAP_KEYSTORE_PASSWORD=${ksp} \
		-e LDAP_DEBUG=${debug} \
		-it --rm -p ${addr}:${sslport}:10636 ${img}:${tag} ${cmd}

stop:
	@- docker rm -f ${name} 2>/dev/null

keystore:
	keytool -validity 365 -genkey -alias adldap -keyalg RSA -keystore ${keystore} \
		-storepass ${storepass} -keypass ${storepass} -dname cn=${dname}

keystorelist:
	keytool -list -v -keystore ${keystore} -storepass ${storepass}

# Remove Exited containers
clean:
	docker ps -a | grep 'Exited' | awk -F " " '{print $$1}' | xargs -I {} docker rm {}
	
