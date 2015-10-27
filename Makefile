NAME=redmine
VERSION=0.0.1

build:
	docker build -t $(NAME):$(VERSION) .

restart: stop start

start:
	docker run -itd \
		--privileged \
		--name $(NAME) \
		-h $(NAME) \
		$(NAME):$(VERSION)

all_container=`docker ps -a -q`
image=`docker images | awk '/^<none>/ { print $$3 }'`

clean: clean_container
	@if [ "$(image)" != "" ] ; then \
		docker rmi $(image); \
	fi

logs:
	docker logs $(NAME)

stop:
	docker rm -f $(NAME)

attach:
	docker exec -it $(NAME) /bin/bash

phplog:
	docker exec -it $(NAME) /usr/bin/tail -f /var/log/php.log

active_container=`docker ps -q`

clean_container:
	@for a in $(all_container) ; do \
		for b in $(active_container) ; do \
			if [ "$${a}" = "$${b}" ] ; then \
				continue 2; \
			fi; \
		done; \
		docker rm $${a}; \
	done
