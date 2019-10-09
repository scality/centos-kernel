DOCKER ?= $(shell command -v docker)
CONTAINER_NAME ?= localhost/centos-kernel-build
CONTAINER_TAG ?= latest

PWD := $(shell pwd)

CONTAINER = $(CONTAINER_NAME):$(CONTAINER_TAG)

RPM_SOURCES = $(shell git ls-files SOURCES)
RPM_SPECS = SPECS/kernel.spec

default: .rpms

.container: Dockerfile build.sh .kernel.metadata $(RPM_SOURCES) $(RPM_SPECS)
	$(DOCKER) build -t "$(CONTAINER)" .
	touch $@

# Note: SOURCES and SPECS are copied inside the container during its build
# phase, so this stage no longer depends on them. All we do is execute the
# container.
.rpms: .container
	mkdir -p RPMS; chmod 0777 RPMS
	mkdir -p SRPMS; chmod 0777 SRPMS
	$(DOCKER) run \
		-ti --rm \
		--read-only \
		--network none \
		--name build \
		--tmpfs /home/build/kernel/BUILD:rw,exec,nosuid,nodev,size=16G \
		--tmpfs /home/build/kernel/BUILDROOT \
		-v $(PWD)/RPMS:/home/build/kernel/RPMS:Z \
		-v $(PWD)/SRPMS:/home/build/kernel/SRPMS:Z \
		--tmpfs /var/tmp \
		--tmpfs /tmp \
		"$(CONTAINER)" \
		--without kabichk
	touch $@
