DOCKER_ACCOUNT = bwehrle
APPNAME = forwardbin

COMMIT=$(shell git rev-parse --short HEAD)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

LDFLAGS = -a
DESTDIR ?=

.PHONY: help \
		clean test test-verbose test-coverage test-coverage-html \
		build docker-build docker-push deploy

.DEFAULT_GOAL := help

help: ## Display this help screen
	@echo "Makefile available targets:"
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  * \033[36m%-15s\033[0m %s\n", $$1, $$2}'

clean: ## Clean
	rm -f bin/

dep: ## Get the dependencies
	go mod download

lint: ## Lint the source files
# golangci-lint run --timeout 5m -E golint -e '(method|func) [a-zA-Z]+ should be [a-zA-Z]+'
# gosec -quiet ./...

test: dep ## Run tests
	go test -race -timeout 300s -coverprofile=.test_coverage.txt ./... && \
		go tool cover -func=.test_coverage.txt | tail -n1 | awk '{print "Total test coverage: " $$3}'
	@rm .test_coverage.txt

build: dep ## Build executable
	go build ${LDFLAGS} -o bin/${APPNAME}

docker-build: ## Build docker image
	docker build -t ${DOCKER_ACCOUNT}/${APPNAME}:${COMMIT} .
	docker image prune --force --filter label=stage=intermediate
	docker tag ${DOCKER_ACCOUNT}/${APPNAME}:${COMMIT} ${DOCKER_ACCOUNT}/${APPNAME}:latest

docker-push: ## Push docker image to registry
	docker push ${DOCKER_ACCOUNT}/${APPNAME}:${COMMIT}
	docker push ${DOCKER_ACCOUNT}/${APPNAME}:latest