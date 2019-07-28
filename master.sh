#!/bin/bash
#
# Copyright 2017-present Liu Hongyu
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
OPENSHIFT_RELEASE="$1"
OPENSHIFT_ANSIBLE_BRANCH="$2"
NETWORK_BASE="$3"
VAGRANT_HOME="/home/vagrant"

# Sourcing common functions
. /vagrant/common.sh

#===  FUNCTION  ================================================================
#         NAME:  install_packages
#  DESCRIPTION:  Install all prerequisite packages
# PARAMETER  1:  None
#===============================================================================
function install_packages() {
  yum -y install git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct unzip
  if [[ "$(version ${OPENSHIFT_RELEASE})" -gt "$(version 3.7)" ]]; then
    yum -y install https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.6-1.el7.ans.noarch.rpm
  else
    yum -y install https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.5.9-1.el7.ans.noarch.rpm
  fi
}

#===  FUNCTION  ================================================================
#         NAME:  calculate_host_vars
#  DESCRIPTION:  Set host vars based on openshift release version
# PARAMETER  1:  None
#===============================================================================
function calculate_host_vars() {
  # Pre-define all possible openshift node groups
  HTPASSWORD_FILENAME=", 'filename': '/etc/origin/master/htpasswd'"

  # Prevent error "provider HTPasswdPasswordIdentityProvider contains unknown keys filename"
  # when openshift version is 3.10 or above.
  if [[ "$(version ${OPENSHIFT_RELEASE})" -ge "$(version 3.10)" ]]; then
    NODE_GROUP_MASTER="openshift_node_group_name='node-config-master'"
    NODE_GROUP_INFRA="openshift_node_group_name='node-config-infra'"
    NODE_GROUP_COMPUTE="openshift_node_group_name='node-config-compute'"
    NODE_GROUP_MASTER_INFRA="openshift_node_group_name='node-config-master-infra'"
    NODE_GROUP_ALLINONE="openshift_node_group_name='node-config-all-in-one'"
    unset HTPASSWORD_FILENAME
  else
    NODE_GROUP_MASTER="openshift_node_labels=\"{'node-role.kubernetes.io/master': true}\""
    NODE_GROUP_INFRA="openshift_node_labels=\"{'node-role.kubernetes.io/infra': true}\""
    NODE_GROUP_COMPUTE="openshift_node_labels=\"{'node-role.kubernetes.io/compute': true}\""
    NODE_GROUP_MASTER_INFRA="openshift_node_labels=\"{'node-role.kubernetes.io/infra': true, 'node-role.kubernetes.io/master': true}\""
    NODE_GROUP_ALLINONE="openshift_node_labels=\"{'node-role.kubernetes.io/infra': true, 'node-role.kubernetes.io/master': true, 'node-role.kubernetes.io/compute': true}\""
  fi
}

#===  FUNCTION  ================================================================
#         NAME:  generate_ansible_hosts
#  DESCRIPTION:  Genernate ansible host file into /etc/ansible/hosts
# PARAMETER  1:  None
#===============================================================================
function generate_ansible_hosts() {
  calculate_host_vars
  cat /vagrant/ansible-hosts \
    | sed "s~{{OPENSHIFT_RELEASE}}~${OPENSHIFT_RELEASE}~g" \
    | sed "s~{{NETWORK_BASE}}~${NETWORK_BASE}~g" \
    | sed "s~{{NODE_GROUP_MASTER}}~${NODE_GROUP_MASTER}~g" \
    | sed "s~{{NODE_GROUP_INFRA}}~${NODE_GROUP_INFRA}~g" \
    | sed "s~{{NODE_GROUP_COMPUTE}}~${NODE_GROUP_COMPUTE}~g" \
    | sed "s~{{NODE_GROUP_MASTER_INFRA}}~${NODE_GROUP_MASTER_INFRA}~g" \
    | sed "s~{{NODE_GROUP_ALLINONE}}~${NODE_GROUP_ALLINONE}~g" \
    | sed "s~{{HTPASSWORD_FILENAME}}~${HTPASSWORD_FILENAME}~g" \
    > /etc/ansible/hosts
}

#===  FUNCTION  ================================================================
#         NAME:  setup_ssh
#  DESCRIPTION:  Setup ssh with NO strict host key checking
# PARAMETER  1:  None
#===============================================================================
function setup_ssh() {
  mkdir -p $VAGRANT_HOME/.ssh
  bash -c "echo 'Host *' >> $VAGRANT_HOME/.ssh/config"
  bash -c "echo 'StrictHostKeyChecking no' >> $VAGRANT_HOME/.ssh/config"
  chmod 600 $VAGRANT_HOME/.ssh/config
}

#===  FUNCTION  ================================================================
#         NAME:  perform_setup
#  DESCRIPTION:  Perform setup process
# PARAMETER  1:  None
#===============================================================================
function perform_setup() {
    setup_ssh && generate_ansible_hosts
}

#===  FUNCTION  ================================================================
#         NAME:  fetch_repo
#  DESCRIPTION:  Fetch repo archive based on openshift release version
# PARAMETER  1:  None
#===============================================================================
function fetch_repo() {
  echo "Downloading openshit-ansible repo (${OPENSHIFT_ANSIBLE_BRANCH}) ..."
  curl -sSL https://github.com/openshift/openshift-ansible/archive/${OPENSHIFT_ANSIBLE_BRANCH}.zip \
    > $VAGRANT_HOME/${OPENSHIFT_ANSIBLE_BRANCH}.zip
  unzip ${OPENSHIFT_ANSIBLE_BRANCH}.zip -d $VAGRANT_HOME
  mv $VAGRANT_HOME/openshift-ansible-${OPENSHIFT_ANSIBLE_BRANCH} $VAGRANT_HOME/openshift-ansible
}

#===  FUNCTION  ================================================================
#         NAME:  perform_chown
#  DESCRIPTION:  Change all files and directories inside $VAGRANT_HOME
# PARAMETER  1:  None
#===============================================================================
function perform_chown() {
  chown -R vagrant:vagrant $VAGRANT_HOME
}

#===  FUNCTION  ================================================================
#         NAME:  main
#  DESCRIPTION:  The main entrypoint of the script
# PARAMETER  1:  None
#===============================================================================
function main() {
  install_packages
  perform_setup
  fetch_repo
  perform_chown
}

main $@
