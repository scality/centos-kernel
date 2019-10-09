#!/bin/bash

set -xue -o pipefail

test -d SPECS || (echo "SPECS is not a directory"; exit 1)
test -f SPECS/kernel.spec || (echo "SPECS/kernel.spec is not a file"; exit 1)
test -d SOURCES || (echo "SOURCES is not a directory"; exit 1)

test -d RPMS || (echo "RPMS is not a directory"; exit 1)
test -d SRPMS || (echo "SRPMS is not a directory"; exit 1)
test -w RPMS || (echo "RPMS is not writable"; exit 1)
test -w SRPMS || (echo "SRPMS is not writable"; exit 1)

exec rpmbuild --define "%_topdir $(pwd)" -ba --target=$(uname -m) SPECS/kernel.spec "$@"
