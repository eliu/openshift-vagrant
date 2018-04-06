# OpenShift Vagrant

[![Licensed under Apache License version 2.0](https://img.shields.io/github/license/openshift/origin.svg?maxAge=2592000)](https://www.apache.org/licenses/LICENSE-2.0)

![image](assets/openshift-vagrant-logo.png)

---

## 概述

`OpenShift Vagrant` 项目旨在通过针对目前 OpenShift Origin 各个主流版本进行预配置的 `Vagrantfile` 文件，使开发者在本机快速搭建真正的 OpenShift Origin 集群环境。

## 先决条件

- 主机的内存至少4GB
- 预装 Oracle VirtualBox (v5.1.30)
- 预装 Vagrant (v2.0或更高)
- 预装 Vagrant 插件 vagrant-hostmanager (v1.8.7)

## OpenShift Origin 版本支持

目前本项目预配置且支持以下3个 OpenShift Origin 主版本，他们是：

- [OpenShift Origin 3.7 （默认配置）](https://github.com/openshift/origin/releases/tag/v3.7.1)
- [OpenShift Origin 3.6](https://github.com/openshift/origin/releases/tag/v3.6.1)

不过，支持以后的其他主版本也非常容易，只需要修改对应文件中的版本戳之后另存为新的文件即可。

Vagrant 配置文件默认使用 OpenShift Origin `3.7` 和 openshift-ansible `release-3.7` 分支做为集群安装部署的版本，不过您也可以很容易更改这个默认值，只需要调整以下两个变量即可：

1. `OPENSHIFT_RELEASE`
2. `OPENSHIFT_ANSIBLE_BRANCH`

调整时请注意 Origin 版本和 openshift-ansible 分支的对应关系，具体见下表：

| OpenShift Origin 版本 | openshift-ansible 分支 |
| --- | --- |
| 3.6 | release-3.6 |
| 3.7 | release-3.7 |


## 使用方法

在调整了对应的版本之后，接下来就可以准备启动 Vagrant 虚拟机和部署 OpenShift Origin 集群了。

Vagrant 会创建并启动三台 VirtualBox 虚拟机，网段由变量 `NETWORK_BASE` 指定。 具体信息如下表：

| VM 节点 | 节点 IP | 角色 |
| --- | --- | --- |
| master | #{NETWORK_BASE}.101 | node, master, etcd |
| node01 | #{NETWORK_BASE}.102 | node |
| node02 | #{NETWORK_BASE}.103 | node |

### 启动 Vagrant 虚拟机

```bash
$ vagrant up
```

### 设置节点间互访的 SSH 秘钥

```bash
$ vagrant provision --provision-with master-key,node01-key,node02-key
```

### 安装并部署 OpenShift Origin 集群

```bash
$ vagrant ssh master -c 'ansible-playbook /home/vagrant/openshift-ansible/playbooks/byo/config.yml'
```

### `oc-up.sh`

以上三个启动步骤已经组织到一个 Shell 脚本中，您只需要在项目主目录执行以下命令既可完成所有启动步骤：

```bash
$ ./oc-up.sh
```

### 访问 Web Console

在浏览器中打开 https://master.example.com:8443/ ，若一切正常，您将会看见 Origin 的登陆页面。默认的登陆账户为 **admin/handhand**

*Have fun with OpenShift Origin and Vagrant :p*