FROM centos:7.6.1810

# https://wiki.centos.org/HowTos/I_need_the_Kernel_Source#head-a8dae925eec15786df9f6f8c918eff16bf67be0d
RUN yum install -y \
        asciidoc audit-libs-devel bash bc binutils binutils-devel bison diffutils elfutils \
        elfutils-devel elfutils-libelf-devel findutils flex gawk gcc gettext gzip hmaccalc hostname java-devel \
        m4 make module-init-tools ncurses-devel net-tools newt-devel numactl-devel openssl \
        patch pciutils-devel perl perl-ExtUtils-Embed pesign python-devel python-docutils redhat-rpm-config \
        rpm-build sh-utils tar xmlto xz zlib-devel \
        && \
    yum install -y \
        git \
        && \
    yum clean all

RUN useradd -d /home/build -m -U build
USER build

WORKDIR /home/build
RUN git clone https://git.centos.org/git/centos-git-common.git

# Create `.git` to trick `get_sources.sh`
RUN mkdir kernel kernel/.git kernel/SOURCES kernel/SPECS
WORKDIR /home/build/kernel

COPY build.sh .

COPY .kernel.metadata .
RUN /home/build/centos-git-common/get_sources.sh -b c7

COPY SOURCES/* SOURCES/
COPY SPECS/kernel.spec SPECS/

ENTRYPOINT ["/home/build/kernel/build.sh"]
