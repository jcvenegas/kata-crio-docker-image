FROM ubuntu:18.04 AS builder
ARG DESTDIR=/tmp/crio/opt/kata

RUN apt-get update
RUN apt-get install -y software-properties-common

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

RUN apt-get install -y curl sudo

RUN curl -L https://gist.githubusercontent.com/jcvenegas/7fa77c07aac881f5cc08abd6fb36558b/raw/install-golang.sh | bash
RUN cp /usr/local/go/bin/go /usr/bin/go

ARG CRIO_VERSION=v1.14.2
ARG PREFIX=/tmp/crio/opt/kata
RUN git clone https://github.com/cri-o/cri-o.git
WORKDIR /cri-o
RUN git checkout $CRIO_VERSION
RUN make
RUN make install
RUN make install.config
RUN make install.systemd
RUN apt-get install -y tree
RUN tree /tmp/crio/opt/kata
RUN sed -i 's/\/usr\/local/\/opt\/kata/g' /tmp/crio/opt/kata/lib/systemd/system/cri-o.service
RUN cat /tmp/crio/opt/kata/lib/systemd/system/cri-o.service
RUN ls /tmp/crio/opt/kata/bin/crio -la

FROM scratch
WORKDIR /root/
COPY --from=builder /tmp/crio .
