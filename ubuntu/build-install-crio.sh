#!/bin/bash
# Copyright (c) 2019 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace


CRIO_VERSION="v1.14.4"
# for crio-o makefile
export DESTDIR=/opt/crio
crio_config_file="${DESTDIR}/etc/crio/crio.conf"
CRIO_REPO="https://github.com/cri-o/cri-o.git"

git clone ${CRIO_REPO} /cri-o
cd /cri-o

git checkout "${CRIO_VERSION}"

#Install 
make
make test-binaries
make install
make install.config
make install.systemd

#Configure
echo "Copy containers policy from CRI-O repo to $containers_config_path"
containers_config_path="${DESTDIR}/etc/containers"
sudo mkdir -p "${containers_config_path}"
sudo install -m0444 test/policy.json "${containers_config_path}"
cat "${containers_config_path}/policy.json"

echo "Set manage_network_ns_lifecycle to true"
network_ns_flag="manage_network_ns_lifecycle"
sudo sed -i "/\[crio.runtime\]/a$network_ns_flag = true" "$crio_config_file"
sudo sed -i 's/manage_network_ns_lifecycle = false/#manage_network_ns_lifecycle = false/' "$crio_config_file"

echo "Add docker.io registry to pull images"
sudo sed -i 's/^#registries = \[/registries = \[ "docker.io" \] /' "$crio_config_file"

cat "${crio_config_file}"
