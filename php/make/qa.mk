.PHONY: qadev
qadev:
ifneq ("$(wildcard ecs.php)","")
	docker run -it \
	--volume ${PWD}:/var/www/html${CACHED_FLAG} \
	--workdir /var/www/html --rm ${PHP_BASE_IMAGE_NAME} \
	vendor/bin/ecs check src --fix
endif

ifneq ("$(wildcard phpstan.neon)","")
	docker run -it \
	--volume ${PWD}:/var/www/html${CACHED_FLAG} \
	--workdir /var/www/html --rm ${PHP_BASE_IMAGE_NAME} \
	vendor/bin/phpstan analyse src
endif
