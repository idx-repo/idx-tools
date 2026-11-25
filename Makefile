.PHONY: all test lint install clean

all: test

test:
	@bash tests/run_tests.sh

lint:
	@bash tests/test_syntax.sh
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "Running shellcheck..."; \
		shellcheck -x -e SC1091 Bash/*.sh tests/*.sh install.sh remove.sh; \
	fi

install:
	@sh install.sh

clean:
	@sh remove.sh
