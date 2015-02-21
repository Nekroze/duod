SILENCE=> /dev/null 2>&1
COMPILER=dmd
SOURCE=./source
DSCANREPORT=$(SOURCE)/dscanner-report.json

.PHONY: all release debug test docs clean help

# make all 	- Perform unittests and if they succeed then build a release version and documentation.
all: test release docs

# make release 	- Build a release version.
release:
	dub build --compiler $(COMPILER) --build release
	./duod-example --duod-build

# make debug 	- Build a debug version.
debug:
	dub build --compiler $(COMPILER)
	./duod-example --duod-build

# make test 	- Execute unittests with coverage output.
test:
	dub test --compiler $(COMPILER) --build unittest

# make coverage - Report on code coverage.
coverage:
	dub test --compiler $(COMPILER) --build cov

# make style 	- Report on code style utilizing Dscanner.
style:
	dscanner --report $(SOURCE) > $(DSCANREPORT)

# make docs 	- Build documentation with ddox.
docs:
	dub build --compiler $(COMPILER) --build ddox

# make clean 	- Dub build clean.
clean:
	dub clean

# make help 	- Displays help.
help:
	@egrep "^# make" Makefile
