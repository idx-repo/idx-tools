.PHONY: all test lint install clean

all: test

test:
	@bash tests/run_tests.sh

lint:
	@bash tests/test_syntax.sh

install:
	@sh install.sh

clean:
	@sh remove.sh
