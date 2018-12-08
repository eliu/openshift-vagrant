# OpenShift Vagrant

[![Licensed under Apache License version 2.0](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

## 概述

`OpenShift Vagrant` 项目旨在通过针对目前 OKD 各个主流版本进行预配置的 `Vagrantfile` 文件，使开发者在本机快速搭建真正的 OKD 集群环境。

## 先决条件

- 主机的内存至少4GB
- 预装 Oracle VirtualBox (v5.1.30)
- 预装 Vagrant (v2.0或更高)
- 预装 Vagrant 插件 vagrant-hostmanager (v1.8.7)

## OKD 版本支持

目前本项目预配置且支持以下3个 OKD 主版本，他们是：

- [OKD v3.10（默认配置）](https://github.com/openshift/origin/releases/tag/v3.10.0)
- [OKD v3.9 ](https://github.com/openshift/origin/releases/tag/v3.9.0)
- [OKD v3.7](https://github.com/openshift/origin/releases/tag/v3.7.2)
- [OKD v3.6](https://github.com/openshift/origin/releases/tag/v3.6.1)

> **注意：**
>
> 由于 `openshift-ansible` 存在 RPM 仓库的错误配置问题，OKD v3.11.0 目前无法正确部署。此外，这个版本的 OKD 也比之前版本更加“重”，启动它所需的内存也比之前的版本要更多。
>
> 如果以上问题已经解决并且您本机也有足够的内存（16GB最佳），那么您只需要修改变量 `OPENSHIFT_RELEASE` 的值为 `3.11`即可部署这个版本的集群，无需额外的配置。

不过，支持以后的其他主版本也非常容易，只需要修改对应文件中的版本戳之后另存为新的文件即可。

Vagrant 配置文件默认使用 OKD `3.10` 和 openshift-ansible `release-3.10` 分支做为集群安装部署的版本，不过您也可以很容易更改这个默认值，只需要调整以下两个变量即可：

1. `OPENSHIFT_RELEASE`
2. `OPENSHIFT_ANSIBLE_BRANCH`

调整时请注意 Origin 版本和 openshift-ansible 分支的对应关系，具体见下表：

| OKD 版本 | openshift-ansible 分支 |
| --- | --- |
| 3.10.x | release-3.10 |
| 3.9.x | release-3.9 |
| 3.7.x | release-3.7 |
| 3.6.x | release-3.6 |


## 使用方法

在调整了对应的版本之后，接下来就可以准备启动 Vagrant 虚拟机和部署 OKD 集群了。

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

### 安装并部署 OKD 集群

安装 Origin 3.7 或之前的版本时，运行以下命令：

```bash
$ vagrant ssh master -c 'ansible-playbook /home/vagrant/openshift-ansible/playbooks/byo/config.yml'
```

安装 Origin 3.8 以上版本时，运行以下命令：

```bash
vagrant ssh master \
        -c 'ansible-playbook /home/vagrant/openshift-ansible/playbooks/prerequisites.yml &&
            ansible-playbook /home/vagrant/openshift-ansible/playbooks/deploy_cluster.yml'
```

### `oc-up.sh`

以上三个启动步骤已经组织到一个 Shell 脚本中，您只需要在项目主目录执行以下命令既可完成所有启动步骤：

```bash
$ ./oc-up.sh
```

### 访问 Web Console

在浏览器中打开 https://master.example.com:8443/ ，若一切正常，您将会看见 Origin 的登陆页面。默认的登陆账户为 **admin/handhand**

*Have fun with OKD and Vagrant :p*