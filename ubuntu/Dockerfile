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

ARG CRIO_VERSION=v1.14.4
ARG DESTDIR=/opt/crio
ARG containers_config_path="${DESTDIR}/etc/containers"
ARG network_ns_flag="manage_network_ns_lifecycle"
ARG crio_config_file="${DESTDIR}/etc/crio/crio.conf"
ARG CRIO_REPO="https://github.com/cri-o/cri-o.git"

RUN git clone ${CRIO_REPO} /cri-o
WORKDIR /cri-o

RUN git checkout "${CRIO_VERSION}"

#Install 
RUN make
RUN make test-binaries
RUN make install
RUN make install.config
RUN make install.systemd

#Configure
RUN echo "Copy containers policy from CRI-O repo to $containers_config_path"
RUN sudo mkdir -p "${containers_config_path}"
RUN sudo install -m0444 test/policy.json "${containers_config_path}"
RUN cat "${containers_config_path}/policy.json"

RUN echo "Set manage_network_ns_lifecycle to true"
RUN sudo sed -i "/\[crio.runtime\]/a$network_ns_flag = true" "$crio_config_file"
RUN sudo sed -i 's/manage_network_ns_lifecycle = false/#manage_network_ns_lifecycle = false/' "$crio_config_file"
RUN cat "${crio_config_file}"

RUN cd "${DESTDIR}" && tree

FROM scratch
WORKDIR /
COPY --from=builder "/opt/crio" /crio-rootfs
