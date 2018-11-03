# OpenShift Vagrant

[![Licensed under Apache License version 2.0](https://img.shields.io/github/license/openshift/origin.svg?maxAge=2592000)](https://www.apache.org/licenses/LICENSE-2.0)

![image](assets/openshift-vagrant-logo.png)

---

## Overview

The `OpenShift Vagrant` project aims to make it easy to bring up a real OpenShift Origin cluster by providing pre-configured `Vagrantfile` of several major versions of Origin on your local machine.

## Prerequisite

- Host machine must have at least 4GB memory
- Oracle VirtualBox installed on your host machine
- Vagrant (2.0 or above) installed on your host machine
- Vagrant plugin `vagrant-hostmanager` must be installed

## OpenShift Origin Version Support

Currently this project pre-configured and support 3 major versions of the OpenShift Origin, which are

- [OpenShift Origin 3.10 (default)](https://github.com/openshift/origin/releases/tag/v3.10.0)
- [OpenShift Origin 3.9](https://github.com/openshift/origin/releases/tag/v3.9.0)
- [OpenShift Origin 3.7](https://github.com/openshift/origin/releases/tag/v3.7.2)
- [OpenShift Origin 3.6](https://github.com/openshift/origin/releases/tag/v3.6.1)

But, it's very easy to customize the respected ansible hosts file in order to support other incoming major versions.

The `Vagrantfile` uses Origin `3.10` and openshift-ansible `release-3.10` branch by default. Feel free to adjust your versions by updating the following 2 variables in Vagrantfile:

1. `OPENSHIFT_RELEASE`
2. `OPENSHIFT_ANSIBLE_BRANCH`

The following table lists the corresponding version relationships between Origin and openshift-ansible:

| OpenShift Origin version | openshift-ansible branch |
| --- | --- |
| 3.10.x | release-3.10 |
| 3.9.x | release-3.9 |
| 3.7.x | release-3.7 |
| 3.6.x | release-3.6 |


## Getting Started

After adjusting your expected version information, now it's time to bring your cluster up and running. 

This Vagrantfile will create 3 VMs in VirtualBox and the network base will be specified by variable `NETWORK_BASE`.

Checkout the table below for more details:

| VM Node | Private IP | Roles |
| --- | --- | --- |
| master | #{NETWORK_BASE}.101 | node, master, etcd |
| node01 | #{NETWORK_BASE}.102 | node |
| node02 | #{NETWORK_BASE}.103 | node |

### Bring Vagrant Up

```bash
$ vagrant up
```

### Provisioning Private Keys

```bash
$ vagrant provision --provision-with master-key,node01-key,node02-key
```

### Install Origin Cluster Using Ansible

Run the following command if you would like to install origin previous to **release-3.8**:

```bash
$ vagrant ssh master -c 'ansible-playbook /home/vagrant/openshift-ansible/playbooks/byo/config.yml'
```

Run the following command for origin 3.8 or above:

```bash
vagrant ssh master \
        -c 'ansible-playbook /home/vagrant/openshift-ansible/playbooks/prerequisites.yml &&
            ansible-playbook /home/vagrant/openshift-ansible/playbooks/deploy_cluster.yml'
```

### `oc-up.sh`

The above 3 steps have been grouped together as one script for you. To bring your cluster up, just use the following command:

```bash
$ ./oc-up.sh
```

### Open Web Console

In browser of your host, open the following page: https://master.example.com:8443/ and you should see OpenShift Web Console login page. The default login account is **admin/handhand**

*Have fun with OpenShift Origin and Vagrant :p*