#################################################################################
# GLOBALS                                                                       #
#################################################################################

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Run Jupyter lab
build:
	@echo "+ $@"
	@tox -e build
.PHONY: build

## Run dbt debug
dbt-debug:
	@echo "+ $@"
	@tox -e dbt -- debug
.PHONY: dbt-debug

## Run dbt seed
dbt-seed:
	@echo "+ $@"
	@tox -e dbt -- seed
.PHONY: dbt-seed

## Run dbt run
dbt-run:
	@echo "+ $@"
	@tox -e dbt -- run
.PHONY: dbt-run

## Run dbt staging models
dbt-run-staging:
	@echo "+ $@"
	@./utils.sh 'stg_' run
.PHONY: dbt-run-staging

## Run dbt intermediate models
dbt-run-intermediate:
	@echo "+ $@"
	@./utils.sh 'int_' run
.PHONY: dbt-run-intermediate

## Run dbt marts models
dbt-run-marts:
	@echo "+ $@"
	@./utils.sh 'fct_' run
.PHONY: dbt-run-marts

## Run dbt test
dbt-test:
	@echo "+ $@"
	@tox -e dbt -- test
.PHONY: dbt-test

## Run tests on dbt staging models
dbt-test-staging:
	@echo "+ $@"
	@./utils.sh 'stg_' test
.PHONY: dbt-test-staging

## Run tests on dbt intermediate models
dbt-test-intermediate:
	@echo "+ $@"
	@./utils.sh 'int_' test
.PHONY: dbt-test-intermediate

## Run tests on dbt marts models
dbt-test-marts:
	@echo "+ $@"
	@./utils.sh 'fct_' test
.PHONY: dbt-test-marts

## Run dbt run-operations to grant usage
dbt-grant-usage:
	@echo "+ $@"
	@tox -e dbt-grant-usage
.PHONY: dbt-grant-usage

## Run dbt snapshot
dbt-snapshot:
	@echo "+ $@"
	@tox -e dbt -- snapshot
.PHONY: dbt-snapshot

## Run dbt docs
dbt-docs:
	@echo "+ $@"
	@tox -e dbt -- docs generate
	@tox -e dbt -- docs serve --host localhost --port 8002
.PHONY: dbt-docs

## Run dbt clean
dbt-clean:
	@echo "+ $@"
	@tox -e dbt -- clean
.PHONY: dbt-clean

## Run DBT project evaluator
dbt-project-evaluator:
	@echo "+ $@"
	@tox -e dbt -- build --select package:dbt_project_evaluator
.PHONY: dbt-project-evaluator

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################



#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
