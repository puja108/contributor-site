# Copyright 2018 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DOCKER		 ?= docker
DOCKER_RUN	 := $(DOCKER) run --rm -it -v $(CURDIR):/src
HUGO_VERSION := 0.55.0
DOCKER_IMAGE := klakegg/hugo:$(HUGO_VERSION)-ext

.DEFAULT_GOAL	:= help

.PHONY: targets docker-targets
targets: help render serve clean-all clean-build clean-content
docker-targets: docker-image docker-build docker-serve docker-gen-site docker-gen-site-ci

help: ## Show this help text.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

server: ## Run Hugo locally (if Hugo "extended" is installed locally)
	hugo server \
		--buildDrafts \
		--buildFuture

docker-render: ## Build the site using Hugo within a Docker container (equiv to render).
	$(DOCKER_RUN) $(DOCKER_IMAGE) --ignoreCache --minify

docker-server: ## Run Hugo locally within a Docker container (equiv to server).
	$(DOCKER_RUN) -p 1313:1313 $(DOCKER_IMAGE) server --bind 0.0.0.0

clean: ## Cleans build artifacts
	rm -rf public/ resources/

production-build: ## Builds the production site (this command used only by Netlify)
	hugo \
		--ignoreCache \
		--minify

preview-build: ## Builds a deploy preview of the site (this command used only by Netlify)
	hugo \
		--baseURL $(DEPLOY_PRIME_URL) \
		--buildDrafts \
		--buildFuture \
		--ignoreCache \
		--minify
