.PHONY: lint format-check format-apply format-update-patches test

SCRIPTS := $(wildcard bin/*)
deps: $(SCRIPTS)
	@$(foreach script,$^,echo "Fetching for $(script)"; shellpack fetch $(script);)

deps_format: @bin/format.bash
	shellpack fetch @bin/format.bash

deps_lint: @bin/lint.bash
	shellpack fetch @bin/lint.bash

format-check: deps_format
	\@bin/format.bash check

format: deps_format
	\@bin/format.bash apply

lint: deps_format deps_lint
	\@bin/lint.bash
