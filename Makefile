all: build

build:
	@docker build --tag=kkimurak/sameersbn-postgresql .

release: build
	@docker build --tag=kkimurak/sameersbn-postgresql:$(shell cat VERSION) .
