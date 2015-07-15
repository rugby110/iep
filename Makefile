# Map stdin to /dev/null to avoid interactive prompts if there is some failure related to the
# build script.
SBT := cat /dev/null | project/sbt

IVY_CACHE_URL := https://www.dropbox.com/s/fkv9hscqskyxwgc/iep.tar.gz?dl=0

.PHONY: build coverage license get-ivy-cache

ifeq (${TRAVIS_PULL_REQUEST},false)
ifeq (${TRAVIS_TAG},)
travis: get-ivy-cache publish
else
travis: get-ivy-cache release
endif
else
travis: get-ivy-cache build
endif

build:
	echo "Starting build"
	$(SBT) 'inspect tree clean' clean test checkLicenseHeaders

publish:
	echo "Starting publish"
	$(SBT) storeBintrayCredentials
	$(SBT) 'inspect tree clean' clean test checkLicenseHeaders publish

release:
	echo "Starting release"
	$(SBT) storeBintrayCredentials
	$(SBT) 'inspect tree clean' clean test checkLicenseHeaders publish bintrayRelease

coverage:
	$(SBT) clean coverage test coverageReport
	$(SBT) coverageAggregate

license:
	$(SBT) formatLicenseHeaders

get-ivy-cache:
	stty cols 5000
	which java
	#find ${WORKSPACE:-$HOME}/.sbt
	#$(SBT) --version
	curl -L $(IVY_CACHE_URL) -o $(HOME)/ivy.tar.gz
	tar -C $(HOME) -xzf $(HOME)/ivy.tar.gz
