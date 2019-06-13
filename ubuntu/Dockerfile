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

ADD build-install-crio.sh /build-install-crio.sh
RUN /build-install-crio.sh



FROM scratch
WORKDIR /
COPY --from=builder "/opt/crio" /crio-rootfs
