.PHONY: deps-clean _format_deps format-check format _lint_deps lint

SCRIPTS := $(wildcard bin/*)
deps: $(SCRIPTS)
	@$(foreach script,$^,echo "Fetching for $(script)"; sosh fetch $(script);)

deps-clean:
	rm -rf lib/.github_deps
	make deps

_format_deps: @bin/format.bash
	sosh fetch @bin/format.bash

format-check: _format_deps
	\@bin/format.bash check

format: _format_deps
	\@bin/format.bash apply

_lint_deps: @bin/lint.bash
	sosh fetch @bin/lint.bash

lint: _format_deps _lint_deps deps
	\@bin/lint.bash
