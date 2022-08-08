upgrade:
	bash make.sh upgrade

install:
	bash make.sh install

create-secrets:
	bash make.sh create-secret

update:
	bash make.sh update master

cleanup:
	kubectl -n oda-production exec -it deployment/oda-dispatcher -- find -ctime + 2
