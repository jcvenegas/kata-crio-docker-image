FROM ubuntu:18.04 AS builder

RUN apt-get update
RUN apt-get install -y software-properties-common

# crio build deps
RUN apt-add-repository ppa:projectatomic/ppa
RUN apt-get update -qq && apt-get install -y \
		btrfs-tools \
		containers-common \
		git \
		libassuan-dev \
		libdevmapper-dev \
		libglib2.0-dev \
		libc6-dev \
		libgpgme11-dev \
		libgpg-error-dev \
		libseccomp-dev \
		libsystemd-dev \
		libselinux1-dev \
		pkg-config \
		go-md2man \
		cri-o-runc

RUN apt-get install -y curl sudo tree

# Install golang to build crio
RUN curl -L https://gist.githubusercontent.com/jcvenegas/7fa77c07aac881f5cc08abd6fb36558b/raw/install-golang.sh | bash
RUN cp /usr/local/go/bin/go /usr/bin/go

ARG CRIO_VERSION=v1.14.2
ARG DESTDIR=/opt/crio
# PREFIX should include destdir  in crio Makefile :(
ARG PREFIX=${DESTDIR}/usr

RUN git clone https://github.com/cri-o/cri-o.git
WORKDIR /cri-o
RUN git checkout "${CRIO_VERSION}"
RUN make
RUN make install
RUN make install.config
RUN make install.systemd

RUN tree  "${DESTDIR}"

RUN sed -i "s#/usr/local#${PREFIX}#g" "${PREFIX}/lib/systemd/system/cri-o.service"
RUN cat "${PREFIX}/lib/systemd/system/cri-o.service"
RUN mkdir -p "${DESTDIR}/etc/containers"
RUN install -m0444 test/policy.json "${DESTDIR}/etc/containers/"

FROM scratch
WORKDIR /
COPY --from=builder "${DESTDIR}" .
